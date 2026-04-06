#!/bin/bash
# === UNDERVOLT NVIDIA RTX 5090 ===
# ---------------------------------

nvidia-smi -pm 1
nvidia-smi -pl 540
nvidia-smi -lgc 2500,2700
