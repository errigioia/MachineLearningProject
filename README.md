# Waste Type Identification

Image classification of waste objects into **8 classes** (battery, clothing, glass, metal, organic, papery, plastic, undifferentiated), developed as the Machine Learning project work for the MSc in Computer Engineering at the University of Salerno (group `2026_MLinf_gr41`).

The model is evaluated on a **private test set acquired with different cameras and conditions**, on three axes: balanced accuracy (higher is better), GPU memory at inference (< 4 GB) and throughput (higher is better).

## TL;DR — key result

In-distribution validation accuracy was **saturated (0.96–0.98 for any reasonable model) and therefore uninformative**: the real problem is robustness under distribution shift. We probed it with an out-of-distribution (OOD) evaluation on the independent [RealWaste](https://archive.ics.uci.edu/dataset/908/realwaste) dataset (evaluation only — never used for training) and with an internal, assignment-aligned stress test decomposed into four perturbation families (geometric, acquisition, background, resolution).

| Model | Clean val | Hard val (internal stress test) | RealWaste (OOD, 7 classes) |
|---|---|---|---|
| ResNet18 baseline | 0.967 | 0.934 | 0.455 |
| ResNet18 + `acq_mild` recipe | 0.965 | — | 0.492 |
| **RegNetY-1.6GF + `acq_mild` (delivered)** | **0.980** | **0.971** | **0.582** |

**Delivered model:** RegNetY-1.6GF fine-tuned with a mild, calibrated acquisition augmentation (`acq_mild`) and horizontal-flip TTA — **0.30 GB** test memory, **~178 img/s** (~356 without TTA).

## What we learned

- **The baseline had learned dataset-specific shortcuts.** Balanced accuracy collapsed from 0.967 to 0.455 on RealWaste, with the majority class (Clothing, 47% of training data) acting as an *attractor* for uncertain predictions.
- **Only feature-side interventions produced real OOD gains.** A mild, calibrated dose of acquisition-style augmentation (blur, JPEG recompression, photometric jitter, sensor noise) improved OOD accuracy by +0.033 with no in-distribution cost. The effect is dose-dependent (inverted U): the aggressive version of the same augmentation *hurt*.
- **Every decision-boundary intervention failed.** Class-weighted loss, oversampling, CutMix, RandomErasing and a confidence-based reject option all redistributed per-class TPR with zero or negative net effect.
- **A robustness benchmark is reliable only if its perturbations are independent of the training augmentation.** Our first stress test rewarded `geo_rrc` for being robust to its own augmentation (RandomResizedCrop). Decomposing the probe into four assignment-aligned families, with a pre-registered selection rule, overturned the choice.
- **Extra capacity converts into robust — not just clean — accuracy.** RegNetY's advantage over ResNet18 widens under shift (+0.014 clean → +0.029 hard-val).

Full analysis in [`report/Report_Inglese.pdf`](report/Report_Inglese.pdf) (also available [in Italian](report/Report_Italiano.pdf)).

## Repository structure

```
├── notebooks/          # Numbered experiment notebooks (see map below)
├── splits/             # Stratified 80/20 split + 5-fold CV split (CSV protocols)
├── results/            # Per-experiment metrics, confusion matrices, training curves
├── report/             # 10-page project report (EN + IT)
├── slides/             # 5-minute presentation
└── inference.ipynb     # Test script: loads the final weights and exposes predict(X)
```

### Notebook map

| Notebook | Purpose |
|---|---|
| `01_EDA` | Exploratory analysis: class imbalance (10.5×), image conditions |
| `02_MakeSplit`, `02b_MakeSplit_CV` | Stratified split (macro- and sub-classes) + 5-fold CV protocol |
| `03_train_baseline` | ResNet18 baseline (val 0.967) |
| `test_crossdataset_realwaste` | OOD probe on RealWaste → discovery of the 0.455 collapse |
| `04_CrossValidation` | 5-fold stability check (0.960 ± 0.005) |
| `05_train_augmentation` | Photometric augmentation (light / strong) |
| `06_train_imbalance` | Weighted loss vs. weighted sampler |
| `07_train_geometric_aug` | RandomResizedCrop, CutMix |
| `08_*` | Hard-validation stress test, confounder discovery, de-biased 4-family recipe selection |
| `09_*` | Backbone comparison (ResNet18, RegNetY-1.6GF, EffV2-S, ConvNeXt-T) under the frozen recipe |
| `10_*` | Fine-tuning depth: shallow/mid freezing, LP-FT |
| `multiobject_same_class_check` | Robustness to multiple same-class objects (2×2 / 3×3 mosaics) |
| `reject_option_check` | Confidence-based reject option (rejected) |

## Reproducing

1. **Dataset** — not included in this repository (provided by the course instructors; not redistributable). Place it in `dataset/<class_name>/` at the repo root.
2. **Weights** — the final checkpoint `regnety16gf_acq_mild.pth` (~40 MB) is published as a [GitHub Release asset](../../releases). Download it to the repo root.
3. **Environment** — all notebooks run on Google Colab (T4 GPU) with stock PyTorch/torchvision. Training stays under 5 GB of GPU RAM (gradient accumulation for the larger backbones), inference under 4 GB.
4. Run `inference.ipynb`: it loads the weights, and its `predict(X)` takes a uint8 batch of shape `(batch_size, rows, cols, 3)` and returns uint8 labels of shape `(batch_size, 1)`, performing resize, normalization and flip-TTA internally.

## Authors

Gioia Errico, Cutolo Raffaele — University of Salerno, 2026.
