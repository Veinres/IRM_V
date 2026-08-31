# Ionization Region Model

The ionization region model code allows simulating HiPIMS discharges and infering unknown discharge properties using a fitting procedure.

This repository hosts the current Matlab version of the IRM code.

# The repository

This repository contains multiple branches which can be selected on the top left side of the landing page. The [main](https://gitlab.liu.se/irm-group/irm) (default) branch contains the latest stable and tested release (currently none - at the moment it only holds the documentation). The [dev](https://gitlab.liu.se/irm-group/irm/-/tree/dev) branch is for development and contains the most recent changes. In addition to the [main](https://gitlab.liu.se/irm-group/irm/-/tree/main) and [dev](https://gitlab.liu.se/irm-group/irm/-/tree/dev) branches, some other temporary branches might exist for active development. A list of currently active branches can be found in the [Repository/Branches Tab](https://gitlab.liu.se/irm-group/irm/-/branches).

# Getting Started

## Requirements

The IRM Matlab code requires the base install of Matlab (version R2020b or newer, but using the most recent version is recommended). Using an older version of Matlab should also be possible with some slight modifications (For the most part, new features are only used for argument validation). Some advanced features require the Optimization and/or Parallel Computing Toolbox. If these Toolboxes are included in your subscription (typically, academic total-headcount licences include all toolboxes) it is recommended to install them as well. However the code is also be perfectly useable without these.

## Downloading the code

The current version of the IRM Matlab code can be downloaded by simply using the download button next to the blue "clone" button on the top right corner of the main page of this repository.
However, if Git is installed on your machine, cloning the repository instead is recommended. For instructions on how to clone this git repository, please refer to the [Git-Guide](doc/Git-Guide.md).

## Contributing using Git

Actively contributing to this repository requires [Git](https://git-scm.com/), a free and open-source version control software that has estabilshed itself as the industry standard in the past 15 years.

Most Linux distributions come with Git preinstalled. Should this not be the case, it can be found in any common package manager.
Git for Windows, macOS and Linux can be downloaded directly from the official [Git Download page](https://git-scm.com/downloads).

For a quick guide on how to use Git, including how to set it up and getting started on working with this repository, please refer to the [Git-Guide](doc/Git-Guide.md).

## Using the IRM code

For a quick guide on how to use the IRM Matlab code, please refer to the [IRM-Guide](doc/IRM-Guide.md) (WIP).
A brief overview of the theory of the model itself is given in [IRM-Theory](doc/IRM-Theory.md) (WIP).
Relevant functions and scripts and their purposes are listed in the [Documentation](doc/index.md) (WIP).
