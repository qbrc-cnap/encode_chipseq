workflow PrepBamsWorkflow {

    Array[File] bams

    scatter (bam in bams) {
        call sambambaSort {
            input:
                unsortedBam = bam
        }

        call samtoolsRmdup {
            input:
                sortedBam = sambambaSort.sortedBam,
                sortedBamIdx = sambambaSort.sortedBamIdx
        }
    }

    output {
        Array[File] finalRmDupBams = samtoolsRmdup.finalBam
    }
}

task sambambaSort {

    File unsortedBam 
    String bn = basename(unsortedBam)
    String sample_name = basename(unsortedBam, ".merged.bam")

    Int disk_size = 50

    # sambamba takes a file like foo.merged.bam
    # and creates foo.merged.sorted.bam (and the index)
    command {
        mv ${unsortedBam} .
        sambamba sort ${bn}
    }

    output {
        File sortedBam = "${sample_name}.merged.sorted.bam"
        File sortedBamIdx = "${sample_name}.merged.sorted.bam.bai"
    }

    runtime {
        docker: "docker.io/blawney/encode_chipseq:cm-20210907-03"
        cpu: 2
        memory: "16 G"
        disks: "local-disk " + disk_size + " HDD"
        preemptible: 0
    }
}

task samtoolsRmdup {
    File sortedBam
    File sortedBamIdx
    String sample_name = basename(sortedBam, ".merged.sorted.bam")

    Int disk_size = 50

    command {
        samtools markdup -r --output-fmt BAM ${sortedBam} ${sample_name}.merged.sorted.rmdup.bam
    }

    output {
        File finalBam = "${sample_name}.merged.sorted.rmdup.bam"
    }

    runtime {
        docker: "biocontainers/samtools:v1.9-4-deb_cv1"
        cpu: 2
        memory: "16 G"
        disks: "local-disk " + disk_size + " HDD"
        preemptible: 0
    }
}
