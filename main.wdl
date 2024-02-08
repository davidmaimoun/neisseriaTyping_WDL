version 1.0


task TYPING {
    input {
        Array[File] assemblies
    }

    command <<<
        mkdir outputs

        samples=(~{sep=" " assemblies})

        for sample in ${samples[@]};do
            sample_file=$(basename "$sample")
            sample_name="${sample_file%.*}"
            neisseria_typing ${sample_name} ${sample} outputs
        done
    >>>

    output {
        File out = "outputs/typing_report.csv"
    }

    runtime {
        cpu : 8
        memory: "8 GB"
        docker: "davidmaimoun/neisseria_typing:1"

   }
}


task SEROGROUPING {
    input {
        Array[File] assemblies
    }

    command <<<
        mkdir serogroup_results
        mkdir assemblies_dir

        samples=(~{sep=" " assemblies})

        for sample in ${samples[@]};do
            cp ${sample} assemblies_dir
        done

        serogrouping assemblies_dir serogroup_results
        
    >>>

    output {
        File out = "serogrouping_report.csv"
    }


    runtime {
        cpu : 8
        memory: "8 GB"
        docker: "davidmaimoun/neisseria_typing:1"

   }
}


task MERGING {
    input {
        File typing_report
        File serogrouping_report
    }

    command <<<
        mkdir typing_report
        merging ~{typing_report} ~{serogrouping_report}
    >>>

    runtime {
        cpu : 8
        memory: "8 GB"
        docker: "davidmaimoun/neisseria_typing:1"

   }
}



workflow Workflow {
    input {
        Array[File] assemblies

    }
   
    call TYPING {
        input: 
            assemblies = assemblies
    }  

    call SEROGROUPING {
        input: 
            assemblies = assemblies
    } 

    call MERGING {
        input: 
            typing_report = TYPING.out,
            serogrouping_report = SEROGROUPING.out
    }

    

}    

