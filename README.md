# streamRHF: Tree-Based Unsupervised Anomaly Detection for Data Streams

**Description**:  
This is the code related to the [streamRHF paper](https://nonsns.github.io/paper/rossi22aiccsa.pdf), which was a collaboration between Télécom Paris, Huawei Technologies France, and Inria Paris.

streamRHF is an unsupervised anomaly detection algorithm for data streams. Our algorithm builds on
some of the ideas of [Random Histogram Forest (RHF)](https://nonsns.github.io/paper/rossi20icdm.pdf), a state-
of-the-art algorithm for batch unsupervised anomaly detection. Our approach is tree-based which boasts several
appealing properties, such as explainability of the results. We conduct an extensive experimental evaluation on multiple
datasets from different real-world applications. Our evaluation shows that our streaming algorithm achieves comparable average 
precision to RHF while outperforming state-of-the-art streaming approaches for unsupervised anomaly detection with furthermore
limited computational complexity.

Other things to include:

  - **Technology stack**: Cython
  - **Status**:  The code was completed for the publication and has not been updated since. 

## Dependencies

Describe any dependencies that must be installed for this software to work.
This includes programming languages, databases or other storage mechanisms, build tools, frameworks, and so forth.
If specific versions of other software are required, or known not to work, call that out.

## Installation

Detailed instructions on how to install, configure, and get the project running.
This should be frequently tested to ensure reliability. 

## Configuration

If the software is configurable, describe it in detail, either here or in other documentation to which you link.

## Usage

Show users how to use the software.
Be specific.
Use appropriate formatting when showing code snippets.

## Known issues

Document any known significant shortcomings with the software.

## Getting help

Contact the author at stefan <dot> nesic <at> protonmail <dot> com.

## Open source licensing info
1. [TERMS](TERMS.md)
2. [LICENSE](LICENSE)
3. [CFPB Source Code Policy](https://github.com/cfpb/source-code-policy/)

## Credits and references

1. [Random Histogram Forest (RHF)](https://github.com/anrputina/rhf)