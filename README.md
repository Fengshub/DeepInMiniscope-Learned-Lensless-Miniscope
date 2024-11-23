# DeepInMiniscope: Learned Integrated Miniscope
Feng Tian, Ben Mattison, Weijian Yang "DeepLeMiN: Deep-learning-powered Physics-aware Lensless Miniscope"
### Clone this repository:
```
git clone https://github.com/Fengshub/DeepLeMiN-Learned-Lensless-Miniscope
```

## [preprint paper](https://www.biorxiv.org/content/10.1101/2024.05.03.592471v1)

## 2D sample reconstructions
Dataset for 2D reconstruction test of green stained [**lens tissue**](https://drive.google.com/drive/folders/1lsAjVdHU8wLL1I7Y60G6kH1KkP-dSooJ?usp=drive_link) <br /><br />
Input: measured [**image**](https://drive.google.com/file/d/1RM8N0R-_M4KtLYLxMbP1nVtHrzkRl8qo/view?usp=drive_link) of green fluorescent stained lens tissue, dissembled into sub-FOV patches.<br />
Output: the [**reconstructed**](https://drive.google.com/file/d/1rXcDQbROTnVweovR2DKKLYlkijlpa-Bk/view?usp=drive_link) slide containing green lens tissue features.<br />
[**Code**](https://github.com/Fengshub/DeepInMiniscope-Learned-Lensless-Miniscope/blob/main/2D_lenstissue/2D_lenstissue.py) for Multi-FOV ADMM-Net model to generate reconstruction results. The function of each script section is described at the beginning of each section.<br />
[**Code**](https://github.com/Fengshub/DeepInMiniscope-Learned-Lensless-Miniscope/blob/main/2D_lenstissue/lenstissue_2D.m) to display the generated image and reassemble sub-FOV patches.<br />

## 3D sample reconstructions
[**Dataset**](https://drive.google.com/drive/folders/1Zejm5FODAm7GRUgAYJpx1vZBarTAVnNT?usp=drive_link) for 3D reconstruction test of in-vivo mouse brain video recording.<br /><br />
Input: Time-series standard-deviation of difference-to-local-mean weighted raw video.<br />
Output: reconstructed 4-D volumetric video containing 3-dimensional distribution of neural activities.<br />
[**Code**](https://github.com/Fengshub/DeepInMiniscope-Learned-Lensless-Miniscope/blob/main/3D_mouse/3D%20mouse.py) for Multi-FOV ADMM-Net model to generate reconstruction results. The function of each script section is described at the beginning of each section.<br />
[**Code**](https://github.com/Fengshub/DeepInMiniscope-Learned-Lensless-Miniscope/blob/main/3D_mouse/mouse_3D.m) to display the generated image and calculate temporal correlation.<br />

## schematic of imager
![schematicimager](https://github.com/Fengshub/3D-Microscope/blob/main/imgs/schematicimager.PNG)
## assembled imager
![assembleimager](https://github.com/Fengshub/DeepLeMiN-Learned-Lensless-Miniscope/blob/main/imgs/assembleimager.jpg)

