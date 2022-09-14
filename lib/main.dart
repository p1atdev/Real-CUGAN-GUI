import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:window_size/window_size.dart';

const _projectTitle = 'Real-CUGAN-GUI';
const _projectVersion = '1.0.0';

void main() async {
  // おまじない
  WidgetsFlutterBinding.ensureInitialized();

  // スクリーン情報を取得
  var screen = await getCurrentScreen();

  // スクリーンの DPI スケールを取得
  var dpiScale = screen!.scaleFactor;

  // macOS では DPI スケールに関わらず常に1倍で表示する
  // Windows と DPI スケール周りの扱いが違うのかも…？ 1倍でちょうど良いサイズになる
  if (Platform.isMacOS) {
    dpiScale = 1;
  }

  // ウインドウの最小サイズ
  // DPI スケールに合わせて調整する (Windows のみ)
  /// macOS のみ、ウインドウの最小高さから 10px ほど引く
  /// Windows と macOS でウインドウのタイトルバーの高さが異なるため
  double minWidth = 750 * dpiScale;
  double minHeight = (Platform.isMacOS ? 650 : 660) * dpiScale;

  // 左上を起点にしたウインドウのX座標・Y座標
  double top = (screen.visibleFrame.height - minHeight) / 2;
  double left = (screen.visibleFrame.width - minWidth) / 2;

  // ウインドウの位置とサイズを設定
  setWindowFrame(Rect.fromLTWH(left, top, minWidth, minHeight));

  // 最小ウインドウサイズを設定
  // ref: https://zenn.dev/tris/articles/006c41f9c473a4
  setWindowMinSize(Size(minWidth, minHeight));

  // ウィンドウのタイトルを設定
  setWindowTitle(_projectTitle);

  // アプリを起動
  runApp(const RealESRGanGUIApp());
}

class RealESRGanGUIApp extends StatelessWidget {
  const RealESRGanGUIApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _projectTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'M PLUS 2',
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'M PLUS 2'),
        ),
      ),
      home: const MainWindowPage(title: _projectTitle),
    );
  }
}

class MainWindowPage extends StatefulWidget {
  const MainWindowPage({super.key, required this.title});

  final String title;

  @override
  State<MainWindowPage> createState() => _MainWindowPageState();
}

class _MainWindowPageState extends State<MainWindowPage> {
  // 拡大元の画像ファイル
  XFile? inputFile;

  // 拡大元の画像ファイルフォームのコントローラー
  TextEditingController inputFileController = TextEditingController();

  // 保存先のファイルフォームのコントローラー
  TextEditingController outputFileController = TextEditingController();

  // デノイズレベル (デフォルト: -1)
  String denoiseLevel = '-1';

  // 拡大率 (デフォルト: 2倍)
  String upscaleRatio = '2x';

  // 保存形式 (デフォルト: png (ただし拡大元の画像ファイルの形式に合わせられる))
  String outputFormat = 'png';

  // プログレスバー
  double? progress;

  // 拡大処理を実行中かどうか
  bool isProcessing = false;

  // コマンドの実行プロセス
  late Process process;

  void updateOutputFileName() {
    if (inputFile != null) {
      // 保存形式が拡大元の画像ファイルと同じなら、拡張子には拡大元の画像ファイルと同じものを使う
      var extension = outputFormat;
      if (extension ==
          path
              .extension(inputFile!.path)
              .toLowerCase()
              .replaceAll('jpeg', 'jpg')
              .replaceAll('.', '')) {
        extension = path.extension(inputFile!.path).replaceAll('.', '');
      }

      final denoiseLevelText = denoiseLevel == '-1'
          ? 'no-denoise'
          : 'denoise${int.parse(denoiseLevel) + 1}x';

      // 保存先のファイルのパスを (入力画像のファイル名)-upscale-4x.jpg みたいなのに設定
      // 4x の部分は拡大率によって変わる
      // jpg の部分は保存形式によって変わる
      outputFileController.text =
          '${path.withoutExtension(inputFile!.path)}-${denoiseLevelText}-up${upscaleRatio}.${extension}';
    }
  }

  void _onStartButtonPressed() async {
    // すでに処理中なら
    if (isProcessing) {
      // 停止
      process.kill();
      isProcessing = false;

      return;
    }

    // バリデーション
    final isInputOk = _validateInput();

    if (!isInputOk) {
      return; //ダメなら返る
    }

    // 拡大開始
    _upscaleImage();
  }

  bool _validateInput() {
// バリデーション
    if (inputFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('拡大元の画像ファイルが指定されていません！'),
        action: SnackBarAction(
          label: '閉じる',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
      return false;
    }
    if (outputFileController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('保存先のファイルが指定されていません！'),
        action: SnackBarAction(
          label: '閉じる',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
      return false;
    }

    return true;
  }

  void _upscaleImage() async {
    // プログレスバーを開始
    setState(() {
      progress = null;
      isProcessing = true;
    });

    // realesrgan-ncnn-vulkan の実行ファイルのパスを取得
    String executablePath = '';
    if (Platform.isWindows) {
      // Windows: Real-CUGAN-GUI/data/flutter_assets/assets/realesrgan-ncnn-vulkan.exe
      executablePath = path.join(
        path.dirname(Platform.resolvedExecutable),
        'data/flutter_assets/assets/realcugan-ncnn-vulkan.exe',
      );
    } else if (Platform.isMacOS) {
      // macOS: Real-CUGAN-GUI.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/realesrgan-ncnn-vulkan
      executablePath = path.join(
        path.dirname(Platform.resolvedExecutable).replaceAll('MacOS', ''),
        'Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/realcugan-ncnn-vulkan',
      );
    }

    // realcugan-ncnn-vulkan コマンドを実行
    // ワーキングディレクトリを実行ファイルと同じフォルダに移動しておかないと macOS で Segmentation fault になり実行に失敗する
    // 実行ファイルと同じフォルダでないと models/ 以下の学習済みモデルが読み込めないのかも…？
    // ref: https://api.dart.dev/stable/2.18.0/dart-io/Process-class.html
    process = await Process.start(
      executablePath,
      [
        // 拡大元の画像ファイル
        '-i', inputFile!.path,
        // 保存先のファイル
        '-o', outputFileController.text,
        // 拡大率 (4x の x は除く)
        '-s', upscaleRatio.replaceAll('x', ''),
        // デノイズ
        '-n', denoiseLevel,
        // 保存形式
        '-f', outputFormat,
      ],
      workingDirectory: path.dirname(executablePath),
    );

    // 標準エラー出力を受け取ったとき
    List<String> lines = []; // すべてのログを貯めるリスト
    process.stderr.transform(utf8.decoder).forEach((line) {
      // // 22.00% みたいな進捗ログを取得
      // var progressMatch = RegExp(r'([0-9]+\.[0-9]+)%').firstMatch(line);

      // // プログレスバーを更新 (進捗ログを取得できたときのみ)
      // if (progressMatch != null) {
      //   setState(() {
      //     progress = double.parse(progressMatch.group(1) ?? '0');
      //   });

      //   // 失敗したときにエラーログを表示するために受け取ったログを貯めておく
      // } else {
      lines.add(line);
      // }
    });

    // realesrgan-ncnn-vulkan の終了を待つ
    var exitCode = await process.exitCode;

    // この時点で isProcessing が false になっている場合、キャンセルされたものとして扱う
    var isCanceled = false;
    if (isProcessing == false) isCanceled = true;

    // プログレスバーを 100% に
    setState(() {
      progress = 100;
      isProcessing = false;
    });

    // 終了コードが 0 (=成功)
    if (exitCode == 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('拡大した画像を保存しました。'),
        action: SnackBarAction(
          label: '閉じる',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));

      // 終了コードが 0 以外 (エラーで失敗)
    } else {
      if (!mounted) return;

      // キャンセルの場合
      if (isCanceled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('画像の拡大をキャンセルしました。'),
          action: SnackBarAction(
            label: '閉じる',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
        // エラーの場合
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text('画像の拡大に失敗しました'),
                Text('実行ログ:\n${lines.join('').trim()}')
              ],
            ),
          ),
          duration: const Duration(seconds: 20), // 10秒間表示
          action: SnackBarAction(
            label: '閉じる',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      }
    }

    // プログレスバーを 0% に戻す
    setState(() {
      progress = 0;
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [
          Center(
            child: Text('version $_projectVersion',
                style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 28, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    // Expanded で挟まないとエラーになる
                    Expanded(
                      child: TextField(
                        controller: inputFileController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '拡大元の画像ファイル',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        // ファイル選択ボタンが押されたとき
                        onPressed: () async {
                          // 選択を許可する拡張子の一覧
                          final imageTypeGroup = XTypeGroup(
                            label: 'images',
                            extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
                          );

                          // ファイルピッカーを開き、選択されたファイルを格納
                          inputFile = await openFile(
                              acceptedTypeGroups: <XTypeGroup>[imageTypeGroup]);

                          // もし拡大元の画像ファイルが入っていれば、フォームにファイルパスを設定
                          if (inputFile != null) {
                            setState(() {
                              // 拡大元の画像ファイルフォームのテキストを更新
                              inputFileController.text = inputFile!.path;

                              // 保存形式を拡大元の画像ファイルの拡張子から取得
                              // 拡張子が .jpeg だった場合も jpg に統一する
                              outputFormat = path
                                  .extension(inputFile!.path)
                                  .replaceAll('.', '')
                                  .toLowerCase();
                              if (outputFormat == 'jpeg') outputFormat = 'jpg';

                              // 保存先のファイルフォームのテキストを更新
                              updateOutputFileName();
                            });
                          }
                        },
                        icon: const Icon(Icons.file_open_rounded),
                        label: const Text('ファイルを選択',
                            style: TextStyle(fontSize: 16, height: 1.3)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: outputFileController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '保存先のファイル',
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const SizedBox(
                        width: 100,
                        child: Text('デノイズ:', style: TextStyle(fontSize: 16))),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        value: denoiseLevel,
                        items: const [
                          DropdownMenuItem(
                            value: '-1',
                            child: Text('なし'),
                          ),
                          DropdownMenuItem(
                            value: '0',
                            child: Text('控えめ'),
                          ),
                          DropdownMenuItem(
                            value: '1',
                            child: Text('普通'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('強い'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('最強 (崩壊の可能性あり)'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            // デノイズが変更されたらセット
                            denoiseLevel = value ?? 'no-denoise';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const SizedBox(
                        width: 100,
                        child: Text('拡大率:', style: TextStyle(fontSize: 16))),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        value: upscaleRatio,
                        items: const [
                          DropdownMenuItem(
                            value: '2x',
                            child: Text('2倍'),
                          ),
                          DropdownMenuItem(
                            value: '3x',
                            child: Text('3倍'),
                          ),
                          DropdownMenuItem(
                            value: '4x',
                            child: Text('4倍'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            // 拡大率が変更されたらセット
                            upscaleRatio = value ?? '2x';

                            // 保存先のファイルフォームのテキストを更新
                            updateOutputFileName();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const SizedBox(
                        width: 100,
                        child: Text('保存形式:', style: TextStyle(fontSize: 16))),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        value: outputFormat,
                        items: const [
                          DropdownMenuItem(
                            value: 'jpg',
                            child: Text('JPEG 形式'),
                          ),
                          DropdownMenuItem(
                            value: 'png',
                            child: Text('PNG 形式'),
                          ),
                          DropdownMenuItem(
                            value: 'webp',
                            child: Text('WebP 形式'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            // 保存形式が変更されたらセット
                            outputFormat = value ?? 'jpg';

                            // 保存先のファイルフォームのテキストを更新
                            updateOutputFileName();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 54,
                  child: ElevatedButton.icon(
                    // 拡大開始ボタンが押されたとき
                    // 既に拡大処理を実行中のときは拡大処理をキャンセルする
                    onPressed: _onStartButtonPressed,
                    icon:
                        Icon(isProcessing ? Icons.cancel : Icons.image_rounded),
                    label: Text(isProcessing ? 'キャンセル' : '拡大開始',
                        style: const TextStyle(fontSize: 20, height: 1.3)),
                    style: ButtonStyle(
                        backgroundColor: isProcessing
                            ? MaterialStateProperty.all(const Color(0xFFEE525A))
                            : null),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                minHeight: 20,
                value: progress,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
