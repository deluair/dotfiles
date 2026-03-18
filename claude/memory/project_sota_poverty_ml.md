---
name: SOTA poverty mapping ML project
description: Planned research project: deep learning on satellite imagery for sub-district poverty prediction in Bangladesh. DHS access pending approval.
type: project
---

SOTA satellite poverty mapping for Bangladesh using deep learning on Sentinel-2 imagery.

**Why:** Current GIS poverty proxy uses district-level averages (64 units, 0.49-0.53 range, no discrimination). SOTA (Jean et al. 2016, Yeh et al. 2020) uses CNNs on satellite tiles at cluster/village level. This would be a publishable contribution.

**How to apply:** When DHS approval comes through, start this project. Likely in a new repo or under ~/bdpolicylab/ml/.

## Status (as of 2026-03-16)
- DHS Bangladesh 2017-18 GPS dataset: **registered, awaiting approval** (dhsprogram.com, 1-2 days)
- BBS HIES 2022 PDF report: **freely available**, district-level poverty rates downloadable
- GEE pipeline: **ready** (3,936 Sentinel-2 scenes/year, VIIRS, WorldPop, GHSL all accessible)
- GEE auth: **working** (project: gen-lang-client-0432004086)

## Data Plan
- **Training labels:** DHS 2017-18 cluster-level wealth index (~600 GPS clusters, jittered 2-10km)
- **Validation:** BBS HIES 2022 district-level poverty headcount (64 districts)
- **Features:** Sentinel-2 tiles (10m), VIIRS nightlights, WorldPop, GHSL built-up, MODIS NDVI
- **Method:** Transfer learning (ResNet pretrained on ImageNet), fine-tune on DHS wealth clusters
- **Resolution target:** Union parishad level (~4,500 units) prediction from district-level training

## Architecture
1. Extract Sentinel-2 tile composites (annual median, cloud-masked) for each DHS cluster (5km buffer)
2. Extract multi-band features: RGB + NIR + SWIR from S2, nightlights from VIIRS, population from WorldPop
3. Train CNN (ResNet-18 or EfficientNet-B0) with transfer learning on ~1,200 labeled tiles
4. Predict poverty score for every union parishad in Bangladesh
5. Validate district-level aggregates against HIES 2022
6. Publish methodology + results on bdpolicylab.com and as working paper

## Key References
- Jean et al. 2016, Science: "Combining satellite imagery and machine learning to predict poverty"
- Yeh et al. 2020, Nature Communications: "Using publicly available satellite imagery and deep learning to understand economic well-being in Africa"
- Chi et al. 2022, PNAS: "Microestimates of wealth for all low- and middle-income countries"
