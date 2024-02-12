version 1.0


task TYPING {
    input {
        Array[File] assemblies
    }

    command <<<
        mkdir results

        samples=(~{sep=" " assemblies})

        for sample in ${samples[@]};do
            sample_file=$(basename "$sample")
            sample_name="${sample_file%.*}"
            neisseria_typing ${sample_name} ${sample} results
        done
    >>>

    output {
        File out = "results/typing_report.csv"
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
        mkdir results
        mkdir assemblies_dir

        samples=(~{sep=" " assemblies})

        for sample in ${samples[@]};do
            cp ${sample} assemblies_dir
        done

        serogrouping assemblies_dir results
        
    >>>

    output {
        File out = "results/serogroup/serogroup_results.json"
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
        File serogrouping_results
    }

    command <<<
        mkdir typing_report
        merging ~{typing_report} ~{serogrouping_results}
    >>>

     output {
        File out = stdout()
    }

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
            serogrouping_results = SEROGROUPING.out
    }

     meta {
        description: "A Neisseria Meningitidis typing Workflow"
        author: "David Maimoun"
        version: "1.0"
    }
  

}    

