This project demostrats the "No Cancel" problem of AVAssetResourceLoaderDelegate

1. ViewController subclass AVPlayerViewController
2. ViewController loads an AVURLAsset, which resourceLoader.delegate set to AssetLoaderDelegate
3. resourceLoader:didCancelLoadingRequest: works fine on Simulator, but NOT in real device (except first time after relaunching the iPhone, weird...).

