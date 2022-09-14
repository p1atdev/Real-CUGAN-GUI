
# Real-CUGAN-GUI

English version

<div align="center">
    <div>
        <img width="600" src="https://user-images.githubusercontent.com/60182057/190080021-0d999d64-2396-4e39-861d-a25b9314aa24.png" />
    </div>
    <a href="https://github.com/p1atdev/Real-CUGAN-GUI/actions/workflows/build.yaml" alt="Flutter CI">
        <img src="https://github.com/p1atdev/Real-CUGAN-GUI/actions/workflows/build.yaml/badge.svg"/>
    </a>
    <div><a href="README-ja.md">日本語</a> | English</div>
</div>

-----

This is a simple GUI wrapper for a CLI tool [realcugan-ncnn-vulkan](https://github.com/nihui/realcugan-ncnn-vulkan), which is the NCNN (Vulkan) implementation of [Real-CUGAN](https://github.com/bilibili/ailab/tree/main/Real-CUGAN) produced by bilibili.

This tool is based on [Real-ESRGAN-GUI](https://github.com/tsukumijima/Real-ESRGAN-GUI).

## Features

- AI super resolution model for anime images
- i18n
- Windows/macOS support

## Example

| Original                                                                                                                         | Denoise:medium, Scale: 4x                                                                                                        |
| -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| <img width="500"  src="https://user-images.githubusercontent.com/60182057/190086654-6ab4ad53-7bdc-4fa4-ba05-494a8a786031.jpg" /> | <img width="500"  src="https://user-images.githubusercontent.com/60182057/190086752-6918c151-daab-4def-88ce-0ffa77b342be.png" /> |
| <img width="500"  src="https://user-images.githubusercontent.com/60182057/190085903-c4c01ecb-2735-4108-8d98-c37a28c41fc7.jpg" /> | <img width="500"  src="https://user-images.githubusercontent.com/60182057/190085911-0522a7ae-6c66-477c-80e7-dda215548947.jpg" /> |

## Installation

### Windows

Windows 10 or later 64-bit OS only; Windows 8 or earlier and 32-bit OS are not supported.

<!-- <img width="600" src=""> -->

Download `Real-CUGAN-GUI-(version)-windows.zip` from [Releases](https://github.com/p1atdev/Real-CUGAN-GUI/releases).

After downloading, unzip `Real-CUGAN-GUI-(version)-windows.zip` and double-click `Real-CUGAN-GUI.exe` inside.

### macOS

Intel Mac and Apple Silicon (M1, M1 Pro, M2 ...etc) are supported. Apple Silicon seem to be faster than Intel Mac (not tested).

<img width="600" src="https://user-images.githubusercontent.com/60182057/190081710-29296603-db00-470a-9438-542274f40dd8.png">

Download `Real-CUGAN-GUI-(version)-macos.zip` from [Releases](https://github.com/p1atdev/Real-CUGAN-GUI/releases)

After downloading, unzip `Real-CUGAN-GUI-(version)-macos.zip` and move `Real-CUGAN-GUI.app` to `/Applications` folder. Then launch it.

#### Could not start

You can allow starting from System Preferences > Security & Privacy > General. 

also, you can start by executing following commands:

```bash
xattr -drs com.apple.quarantine /Applications/Real-CUGAN-GUI.app
```

## How to use

Select the denoise level and scale-up ratio to perform super-resolution.

There are four denoise levels: None, Moderate, Normal, Strong, and Strongest.

If the original image is rough, setting the denoise level too strongly often results in a blurry image.

There are three magnification ratios: 2x, 3x, and 4x.

There is no significant difference in the content of the rendering whether it is 2x or 4x. The only difference is the increase in the size of the image's height and width.

## Troubleshooting

### Unable to scale up image with error "Failed to enlarge image".

Some combinations of denoise level and magnification rate may not be supported by the original Real-CUGAN ncnn Vulkan and may not be executable. In such cases, changing the denoise level to something else may make it possible to execute.

## License

[MIT License](LICENSE)
