class [Web3Manager] {
  static final [Web3Manager] _singleton = [Web3Manager]._internal();
  factory [Web3Manager]() => _singleton;

  [Web3Manager]._internal();

  // 发送交易币
  Future<[Web3TransactionResultModel]> sendTradingCoin(
    num amount,
    String to, {
    String? address,
    num? predictGasLimit,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();
    address ??= await Config().getUsdcAddress();

    BigInt tempAmount = BigInt.from(
        num.tryParse(amount.toStringAsFixed(4))! * [Web3ConstValue].usdcDecimals);
    if ((address?.isNotEmpty ?? false)) {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].erc20Path,
        contractAddress: address!,
        contractFunctionName: "transfer",
        privatekey: [WalletManager]().getEthPrivateKey(),
        isAddGas: false,
        predictGasLimit: predictGasLimit,
        parameters: [
          EthereumAddress.fromHex(to),
          tempAmount,
        ],
      );
      if (result.isSuccess) {
      //
      }
    }
    return result;
  }

  // 返回方法名
  Future<String> signContractFunction([WalletConnectInfoModel] model) {
    return [Web3ContractsManager]().signContractFunction(
      contractPath: model.abiPath,
      contractAddress: model.contractAddress,
      contractFunctionName: model.name,
      privatekey: [WalletManager]().getEthPrivateKey(),
      parameters: model.list,
    );
  }

  void addEvent() {
    [Web3ContractsManager]().addEvent();
  }

  // 查找方法
  Future<[WalletConnectInfoModel]> findFunction(Map msg) async {
    [WalletConnectInfoModel] info = [WalletConnectInfoModel]();
    List<String> list = [
      [Web3ConstValue].erc20Path,
      [Web3ConstValue].erc721Path,
      [Web3ConstValue].penPath,
      [Web3ConstValue].rewardPath,
      [Web3ConstValue].nftBoxPath,
    ];
    for (var item in list) {
      info = await [Web3ContractsManager]().findFunction(item, msg);
      if (info.name.isNotEmpty) {
        break;
      }
    }
    return info;
  }

  // 查询结果直到完成
  Future<bool> checkTransactionResult(
    String tx, {
    void Function(Timer timer)? cancelCallBack,
  }) {
    return [Web3ContractsManager]()
        .checkTransactionResult(tx, cancelCallBack: cancelCallBack);
  }

  // 查询当前结果, 仅一次
  Future<bool?> checkTransactionResultOnce(
    String tx,
  ) {
    return [Web3ContractsManager]().checkTransactionResultOnce(tx);
  }

  // 链ID
  Future<String> chainId() {
    return [Web3ContractsManager]().chainId();
  }

  // 交易币余额
  Future<String> balanceTradingCoin() async {
    String result = "0";

    List? balanceOf;
    String? contractAddress = await Config().getUsdcAddress();
    if (contractAddress?.isEmpty ?? true) {
      return result;
    }
    try {
      balanceOf = await [Web3ContractsManager]().callContractFunction(
          contractPath: [Web3ConstValue].erc20Path,
          contractAddress: contractAddress!,
          contractFunctionName: "balanceOf",
          privatekey: [WalletManager]().getEthPrivateKey(),
          parameters: [[WalletManager]().getEthPrivateKey().address]);

      [Web3ContractsManager]().callContractFunction(
          contractPath: [Web3ConstValue].erc20Path,
          contractAddress: contractAddress,
          contractFunctionName: "symbol",
          privatekey: [WalletManager]().getEthPrivateKey(),
          parameters: []).then((value) {
        [WalletManager]().setTradingCoinName(value?.first ?? "");
      });
    } catch (e) {
      Log.error(e.toString());
    }
    if (balanceOf?.isNotEmpty ?? false) {
      BigInt dec = BigInt.from(6);
      num bit = pow(10, dec.toInt());
      result = (balanceOf!.first / BigInt.from(bit)).toString();
    }
    return result;
  }

  // 创建助记词
  String createMnemonic() {
    return [Web3ContractsManager]().createMnemonic();
  }

  // 验证助记词
  bool validateMnemonic(String mnemonic) {
    return [Web3ContractsManager]().validateMnemonic(mnemonic);
  }

  // 发送代币
  Future<[Web3TransactionResultModel]> send(
      {required String toAddress, required String ethCount}) async {
    [Web3TransactionResultModel]? result;
    if ([WalletManager]().isHaveWallet()) {
      result = await [Web3ContractsManager]().sendToken(
        toaddress: toAddress,
        privatekey: [WalletManager]().getEthPrivateKey(),
        value: ethCount,
      );
      if (result.isSuccess) {
        //
      }
    }
    return result ?? [Web3TransactionResultModel]();
  }

  // 解析钱包地址
  Future<String> getWalletAddress(Wallet wallet) async {
    return [Web3ContractsManager]().getWalletAddress(wallet);
  }

  // 查询余额
  Future<double> getBalance() async {
    String? address = UserDataCenter().getUserInfo().wallet.address;
    double result = await [Web3ContractsManager]()
        .getBalance(address, [WalletManager]().gasCoinName());
    UserDataCenter().updateBalance([WalletManager]().gasCoinName(), result);
    return result;
  }

  // 查询链gas
  Future<String> getChainGasfee() {
    return [Web3ContractsManager]().getdefaultEthfee();
  }

  // 签名文本
  String signTxt({
    required String txt,
    required EthPrivateKey privateKey,
  }) {
    String result = "";
    try {
      result = [Web3ContractsManager]().signTxt(privateKey, txt);
    } catch (e) {
      Log.error(e.toString());
    }

    return result;
  }

  // 解析文本
  String designTxt({required String txt}) {
    String result = "";
    try {
      result = [Web3ContractsManager]().designTxt(txt);
    } catch (e) {
      Log.error(e.toString());
    }
    return result;
  }

  // 查询sbt等级
  Future<int> checkSBTLevel({String? address}) async {
    num penLevel = 0;
    String sbtAddress = await Config().sbtAddress();
    if (sbtAddress.isEmpty) {
      return -1;
    }
    try {
      List? sbtCountResult = await [Web3ContractsManager]().callContractFunction(
          contractPath: [Web3ConstValue].penPath,
          contractAddress: sbtAddress,
          contractFunctionName: "getId",
          privatekey: [WalletManager]().getEthPrivateKey(),
          parameters: [
            address == null
                ? [WalletManager]().getEthPrivateKey().address
                : EthereumAddress.fromHex(address),
          ]);
      BigInt bigNum = sbtCountResult?[0] ?? BigInt.from(0);
      penLevel = bigNum.toInt();
    } catch (e) {
      Log.error(e.toString());
      penLevel = -2;
    }
    return penLevel.toInt();
  }

  // 查询sdt uri
  Future<String?> checkSBTUri(int level) async {
    String? uri;
    String sbtAddress = await Config().sbtAddress();
    if (sbtAddress.isEmpty) {
      return uri;
    }
    try {
      List? sbtCountResult = await [Web3ContractsManager]().callContractFunction(
          contractPath: [Web3ConstValue].penPath,
          contractAddress: sbtAddress,
          contractFunctionName: "uri",
          privatekey: [WalletManager]().getEthPrivateKey(),
          parameters: [
            BigInt.from(level),
          ]);
      uri = sbtCountResult?[0];
    } catch (e) {
      Log.error(e.toString());
    }
    return uri;
  }

  // 铸造 / 升级
  Future<[Web3TransactionResultModel]> mintNFT({
    num? predictGasLimit,
    int updateToLevel = 1,
    void Function(String tx)? updateTx,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();
    num level = UserDataCenter().getUserInfo().sbt.level;
    if (level >= 0) {
      if (level == 0) {
        result = await doMintPen(
          functionName: "mint",
          toLevel: updateToLevel,
          fromLevel: 0,
          updateTx: updateTx,
          predictGasLimit: predictGasLimit,
        );
      } else if (level < 3 && updateToLevel > level) {
        result = await doMintPen(
          functionName: "upgrade",
          toLevel: updateToLevel,
          fromLevel: level.toInt(),
          updateTx: updateTx,
          predictGasLimit: predictGasLimit,
        );
      }
    }
    return result;
  }

  // 调用合约
  Future<List<dynamic>?> callContract({
    required String contractPath,
    required String contractAddress,
    required String contractFunctionName,
    required List parameters,
  }) {
    return [Web3ContractsManager]().callContractFunction(
        contractPath: contractPath,
        contractAddress: contractAddress,
        contractFunctionName: contractFunctionName,
        privatekey: [WalletManager]().getEthPrivateKey(),
        parameters: parameters);
  }

  // 签名调用
  Future<[Web3TransactionResultModel]> signContractTransaction({
    required String contractPath,
    required String contractAddress,
    required String contractFunctionName,
    required List parameters,
    num? gasLimit,
    num? gasPrice,
  }) async {
    return [Web3ContractsManager]()
        .signContractTransaction(
      contractPath: contractPath,
      contractAddress: contractAddress,
      contractFunctionName: contractFunctionName,
      privatekey: [WalletManager]().getEthPrivateKey(),
      parameters: parameters,
      gasLimit: gasLimit,
    )
        .then((result) {
      record(
        contractPath: contractPath,
        contractAddress: contractAddress,
        contractFunctionName: contractFunctionName,
        parameters: parameters,
        result: result,
      );
      return result;
    });
  }

  Future<num?> estimateGas({
    required String contractPath,
    required String contractAddress,
    required String contractFunctionName,
    required List parameters,
  }) {
    return [Web3ContractsManager]().contractTransactionGas(
      contractPath: contractPath,
      contractAddress: contractAddress,
      contractFunctionName: contractFunctionName,
      privatekey: [WalletManager]().getEthPrivateKey(),
      parameters: parameters,
    );
  }

  // 查询等级对应价格
  Future<String?> checkSBTPrice(int level) async {
    String sbtAddress = await Config().sbtAddress();
    if (sbtAddress.isEmpty) {
      return null;
    }

    List? priceResult = await callContract(
        contractPath: [Web3ConstValue].penPath,
        contractAddress: sbtAddress,
        contractFunctionName: "levelPrice",
        parameters: [
          BigInt.from(level),
        ]);
    if (priceResult?.first == null) {
      return null;
    } else {
      return (priceResult?.first / BigInt.from([Web3ConstValue].usdcDecimals))
          .toString();
    }
  }

// 铸造返佣笔
  Future<[Web3TransactionResultModel]> claim({
    required num deadline,
    required String nonce,
    required String encodedHash,
    required num v,
    required String r,
    required String s,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();
    String sbtAddress = await Config().rebateAddress();
    if (sbtAddress.isEmpty) {
      return result;
    }
    try {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].rewardPath,
        contractAddress: sbtAddress,
        contractFunctionName: "claim",
        privatekey: [WalletManager]().getEthPrivateKey(),
        parameters: [
          BigInt.from(deadline),
          BigInt.tryParse(nonce) ?? BigInt.zero,
          hexToBytes(encodedHash),
          BigInt.from(v),
          hexToBytes(r),
          hexToBytes(s),
        ],
      );
    } catch (e) {
      result.error = e as Exception?;
      Log.error(e.toString());
    }
    if (result.isSuccess) {
     //
    }
    return result;
  }

  // 查询概率
  Future<double> queryGetProbability() async {
    String sbtAddress = await Config().nftBoxAddress();
    List? returnList = await [Web3ContractsManager]().callContractFunction(
      contractPath: [Web3ConstValue].nftBoxPath,
      contractAddress: sbtAddress,
      contractFunctionName: "getProbability",
      privatekey: [WalletManager]().getEthPrivateKey(),
      parameters: [],
    );
    BigInt value = returnList?[0] ?? BigInt.from(0);
    return value.toDouble() / 10000;
  }

  // 查询价格
  Future<double> getPrice() async {
    String sbtAddress = await Config().nftBoxAddress();
    List? returnList = await [Web3ContractsManager]().callContractFunction(
      contractPath: [Web3ConstValue].nftBoxPath,
      contractAddress: sbtAddress,
      contractFunctionName: "getPrice",
      privatekey: [WalletManager]().getEthPrivateKey(),
      parameters: [],
    );
    BigInt price = returnList?[0] ?? BigInt.from(0);
    return price.toDouble() / 1000000;
  }

  // mint 盒子
  Future<[Web3TransactionResultModel]> mintNFTBox(
    int count,
    num needUsdc,
    void Function(String tx)? updateTx, {
    num? limit,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();

    String sbtAddress = await Config().nftBoxAddress();
    if (sbtAddress.isEmpty) {
      return [Web3TransactionResultModel]();
    }

    String? contractAddress = await Config().getUsdcAddress();
    bool isOk = false;
    List? allowance = await callContract(
      contractPath: [Web3ConstValue].erc20Path,
      contractAddress: contractAddress!,
      contractFunctionName: "allowance",
      parameters: [
        [WalletManager]().getEthPrivateKey().address,
        EthereumAddress.fromHex(sbtAddress),
      ],
    );
    BigInt allowanceValue = allowance?.first ?? BigInt.zero;
    if (allowanceValue.toInt() < needUsdc * [Web3ConstValue].usdcDecimals) {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].erc20Path,
        contractAddress: contractAddress,
        contractFunctionName: "approve",
        privatekey: [WalletManager]().getEthPrivateKey(),
        predictGasLimit: limit,
        parameters: [
          EthereumAddress.fromHex(sbtAddress),
          BigInt.from(needUsdc * [Web3ConstValue].usdcDecimals),
        ],
      );
      if (result.isSuccess) {
        if (updateTx != null) {
          updateTx(result.tx!);
        }
        isOk = await [Web3ContractsManager]().checkTransactionResult(result.tx!);
      }
    } else {
      isOk = true;
    }
    if (isOk) {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].nftBoxPath,
        contractAddress: sbtAddress,
        contractFunctionName: "mint",
        privatekey: [WalletManager]().getEthPrivateKey(),
        gasLimit: limit ?? [Web3ConstValue].openNFTBoxLimit,
        parameters: [
          BigInt.from(count),
        ],
      );
      if (result.isSuccess) {
      //
      }
    }

    return result;
  }

  // 铸造笔
  Future<[Web3TransactionResultModel]> doMintPen({
    required String functionName,
    required int toLevel,
    required int fromLevel,
    num? predictGasLimit,
    void Function(String tx)? updateTx,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();
    String sbtAddress = await Config().sbtAddress();
    if (sbtAddress.isEmpty) {
      return result;
    }
    SBTInfoModel model = TransferrCenter().getSBTInfo();
    if (model.nowLevel == null) {
      model = await TransferrCenter().queryPenInfo();
    }

    String? contractAddress = await Config().getUsdcAddress();
    List? allowance = await callContract(
      contractPath: [Web3ConstValue].erc20Path,
      contractAddress: contractAddress!,
      contractFunctionName: "allowance",
      parameters: [
        [WalletManager]().getEthPrivateKey().address,
        EthereumAddress.fromHex(sbtAddress),
      ],
    );
    bool isApprove = false;
    BigInt needValue = BigInt.from(
        (model.getLevelPrice(toLevel) - model.getLevelPrice(fromLevel)) *
            [Web3ConstValue].usdcDecimals);
    if (allowance?.first < needValue) {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].erc20Path,
        contractAddress: contractAddress,
        contractFunctionName: "approve",
        privatekey: [WalletManager]().getEthPrivateKey(),
        predictGasLimit: [Web3ConstValue].approveLimit,
        parameters: [
          EthereumAddress.fromHex(sbtAddress),
          needValue,
        ],
      );
      if (result.isSuccess) {
        isApprove =
            await [Web3ContractsManager]().checkTransactionResult(result.tx!);
      }
    } else {
      isApprove = true;
    }

    if (isApprove) {
      result = await [Web3ContractsManager]().signContractTransaction(
        contractPath: [Web3ConstValue].penPath,
        contractAddress: sbtAddress,
        contractFunctionName: functionName,
        privatekey: [WalletManager]().getEthPrivateKey(),
        predictGasLimit: predictGasLimit,
        parameters: [
          BigInt.from(toLevel),
        ],
      );
      if (result.isSuccess) {
       //
      }
    }
    return result;
  }

  // 转账
  Future<[Web3TransactionResultModel]> transferNFT(
    String penid,
    String toAddress, {
    String? contractAddress,
    num? limit,
  }) async {
    [Web3TransactionResultModel] result = [Web3TransactionResultModel]();
    contractAddress = await Config().nftAddress();
    if (contractAddress.isEmpty) {
      return result;
    }

    if ([WalletManager]().isHaveWallet() && num.tryParse(penid) != null) {
      result = await [Web3ContractsManager]().signContractTransaction(
          contractPath: [Web3ConstValue].erc721Path,
          contractAddress: contractAddress,
          contractFunctionName: "transferFrom",
          privatekey: [WalletManager]().getEthPrivateKey(),
          isAddGas: false,
          predictGasLimit: limit,
          parameters: [
            [WalletManager]().getEthPrivateKey().address,
            EthereumAddress.fromHex(toAddress),
            BigInt.from(num.tryParse(penid)!),
          ]);
      if (result.isSuccess) {
      //
      }
    }
    return result;
  }

  // **过时**
  createWallet(String pwd) {
    [Web3ContractsManager]().createWallet(password: pwd);
  }
}
