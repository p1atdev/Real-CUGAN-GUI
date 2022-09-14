
# Real-CUGAN-GUI

日本語版

<img width="600" src="https://user-images.githubusercontent.com/60182057/190080021-0d999d64-2396-4e39-861d-a25b9314aa24.png">

-----

bilibili の製作した [Real-CUGAN](https://github.com/bilibili/ailab/tree/main/Real-CUGAN) の NCNN (Vulkan) 実装である、[realcugan-ncnn-vulkan](https://github.com/nihui/realcugan-ncnn-vulkan) という CLI ツールのかんたんな GUI ラッパーです。

このツールは [Real-ESRGAN-GUI](https://github.com/tsukumijima/Real-ESRGAN-GUI) という Real-ESRGAN の GUI ツールをもとに作られています。

- 説明
  - [日本語](README-ja.md)
  - [English](README.md)

## 機能

- イラスト特化の超解像
- 多言語対応
- Windows/macOS サポート

## 例

| 元画像                                                                                                                           | デノイズ:普通、拡大: 4 倍                                                                                                        |
| -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| <img width="500"  src="https://user-images.githubusercontent.com/60182057/190086654-6ab4ad53-7bdc-4fa4-ba05-494a8a786031.jpg" /> | <img width="500"  src="https://user-images.githubusercontent.com/60182057/190086752-6918c151-daab-4def-88ce-0ffa77b342be.png" /> |
| <img width="500"  src="https://user-images.githubusercontent.com/60182057/190085903-c4c01ecb-2735-4108-8d98-c37a28c41fc7.jpg" /> | <img width="500"  src="https://user-images.githubusercontent.com/60182057/190085911-0522a7ae-6c66-477c-80e7-dda215548947.jpg" /> |

## インストール

### Windows

Windows 10 以降の 64bit OS にのみ対応しています。Windows 8 以前と、32bit OS は対応していません。

<!-- <img width="600" src=""> -->

_画像は準備中です_

[Releases](https://github.com/p1atdev/Real-CUGAN-GUI/releases) ページから、最新の Real-CUGAN-GUI をダウンロードします。  
`Real-CUGAN-GUI-(バージョン)-windows.zip` をダウンロードしてください。

ダウンロードが終わったら `Real-CUGAN-GUI-(バージョン)-windows.zip` を適当なフォルダに解凍し、中の `Real-CUGAN-GUI.exe` をダブルクリックします。  
適宜ショートカットをデスクトップに作成してみても良いでしょう。

### macOS

Intel Mac と Apple Silicon (M1, M1 Pro, M2 ...etc) の両方に対応しています。  
Intel Mac よりも、Apple Silicon 搭載 Mac の方が画像の生成が速い印象です (Intel Mac でも最上級グレードの機種ならまた違うのかも)。

<img width="600" src="https://user-images.githubusercontent.com/60182057/190081710-29296603-db00-470a-9438-542274f40dd8.png">

[Releases](https://github.com/p1atdev/Real-CUGAN-GUI/releases) ページから、最新の Real-CUGAN-GUI をダウンロードします。  
`Real-CUGAN-GUI-(バージョン)-macos.zip` をダウンロードしてください。

ダウンロードが終わったら `Real-CUGAN-GUI-(バージョン)-macos.zip` を解凍し、中の `Real-CUGAN-GUI.app` をアプリケーションフォルダに移動します。  
その後、`Real-CUGAN-GUI.app` をダブルクリックしてください。

#### 起動できない場合

環境設定 > セキュリティとプライバシー > 一般 から起動を許可することができます

また、以下を実行することでも起動可能です

```bash
xattr -drs com.apple.quarantine /Applications/Real-CUGAN-GUI.app
```

## 使い方

デノイズレベルと拡大率を選択して画像を超解像します。

デノイズレベルは 4 種類あり、「なし」「控えめ」「普通」「強め」「最強」です。

元画像が荒い場合、デノイズレベルを強くしすぎるとのっぺりとしてしまうことが多いです。

拡大率は 3 種類あり、「2倍」「3倍」「4倍」です。

2 倍でも 4 倍でも描画内容に大きな差異はありません。画像の縦横サイズが大きくなるだけです。

## トラブルシューティング

### 「画像の拡大に失敗しました」というエラーで画像の拡大ができない

デノイズレベルと拡大率の組み合わせによっては元の Real-CUGAN ncnn Vulkan が対応していないため実行できない場合があります。その時はデノイズレベルを他のものに変更することで実行できるようになることがあります。

### クラッシュする

原因わかりません。

## License

[MIT License](LICENSE)
