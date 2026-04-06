# Single Circle Electrode 3D

This repository contains MATLAB code for a 3D simulation of voltage and current density distribution under a circular surface electrode.

## Overview

The model uses a simple finite-difference approach to solve the steady-state voltage distribution in a conductive medium. A circular electrode is placed on the surface at `z = 0`, and the conductive region is defined below the surface as a gel/skin-like layer. The code then computes:

- voltage distribution
- electric field
- current density
- radial distribution of normal current density at the surface

## Model Description

- **Domain size:** 10 cm × 10 cm × 10 cm
- **Grid resolution:** 40 points in each direction
- **Electrode shape:** circular
- **Electrode radius:** 2.5 cm
- **Electrode location:** centered on the bottom surface
- **Applied voltage:** 1 V
- **Conductive region:** `z <= 5 cm`
- **Non-conductive region:** `z > 5 cm`

The voltage field is solved iteratively using a discrete Laplace equation. From the voltage solution, the electric field and current density are calculated.

## File

- `SingleCircleElectrode3D.m` — main MATLAB script for running the simulation and visualizing the results

## Outputs

The script generates:

1. A 3D visualization of current density in the conductive region
2. A scatter plot of normal current density (`Jz`) versus radial distance from the electrode center
3. A radial bin-averaged curve for surface current density distribution

## Usage

1. Open MATLAB
2. Place `SingleCircleElectrode3D.m` in your working directory
3. Run the script:

```matlab
SingleCircleElectrode3D
