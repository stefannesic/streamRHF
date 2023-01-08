# streamRHF
### Tree-Based Unsupervised Anomaly Detection for Data Streams

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
  - **Status**:  The code was completed for the publication and is no longer updated.

## Dependencies

Install all dependencies as follows: 
`pip install -r requirements.txt`

## Installation

If you attempted to previously install the module, you may use `make clean` to clear all build and cache files. 

1. Build the streamRHF module: `make`
2. Install the module to your local user: `make install`

## Usage

An example script found in `scripts/insertion_script.py` is provided that details how the streamRHF module was used in the experiments detailed in the paper.

## Getting help

Contact the author at stefan \<dot\> nesic \<at\> protonmail \<dot\> com.

## Open source licensing info

1. [LICENSE](LICENSE)

## Credits and references

1. [Random Histogram Forest (RHF)](https://github.com/anrputina/rhf)