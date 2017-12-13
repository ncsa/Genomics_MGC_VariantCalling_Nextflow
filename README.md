# Genomics_MGC_VariantCalling_Nextflow

1. Objective:
Replicate GATK Best Practices workflow in Nextflow instead of Bash

2. Workflow Architecture

  2.1 Basic Coding Principles
  Nothing should be hard-coded - paths to executables, paths to sample reads/files, reference files can all be modified when program is run
  Comments in code
  Documentation in README files
  
  2.2 Workflow Best Practices
  Must be robust against hardware/software/data failure
    user option on whether to fail or continue the whole workflow when something goes wrong with one of the sample
    produce logs on failure; capture exit codes; email analyst with Nextflow error
    check everything before workflow actually runs:
    check that all executables exist
    check that all parameters are valid
    return specific information on parameter and line where error has occurred
  
  Encapsulation for ease of use
    parameters can be modified without touching workflow code itself

  2.3 Workflow Overview
  
  Nextflow is a reactive workflow framework and DSL based on the dataflow programming model designed to facilitate easy construction of computational pipelines. Based off the idea of
  Linux as a central data science language, Nextflow serves as a wrapper for simple command line and scripting tool that allows for more complex functions 
  to be carried out. 
  
  Work in Nextflow is comprised of a series of processes and channels. Processes are independent functions which can wrap Python or Perl scripts as well as the Groovy-based Nextflow script. Due to their isolation,
  they cannot interact with each other; instead, communication between processes is facilitated by FIFO queues, called channels, which serve to link processes to each other.
  Each process has an 'input' and 'output', in which channels can be specified. These inputs and outputs define the workflow execution order.
  
  All processes, channels, and parameters are coded into a single file, which can be run using the command "nextflow [filename]" once the nextflow
  module has been loaded. Parameters can be modified when running the program using the double dash "--" followed by the parameter name and then the new value for that parameter.
  For example, --manyFiles "path/toNewSampleFile" would change the params.manyFiles to the newly specified path. 
  
  
  
  
  
  
