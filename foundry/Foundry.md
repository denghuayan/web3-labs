#                       **Foundry 操作手册**

Foundry 是一个智能合约开发工具。用于管理你的依赖关系、编译项目、运行测试、部署，并允许你通过命令行和 Solidity 脚本与链交互。

Foundry分为四个板块：

**Forge**：用来测试、构建和部署您的智能合约。
**Cast**： 用于执行以太坊RPC调用的命令行工具。 可以进行智能合约调用、发送交易或检索任何类型的链数据。
**Anvil**：Foundry附带的本地测试网节点。 可以使用它从前端测试合约或通过 RPC 进行交互。
**Chisel**：随 Foundry 提供的高级 Solidity REPL可以在命令行快速的有效的实时的写合约，测试合约。可用于在本地或分叉网络上快速测试 Solidity 片段。

## 中文文档
  https://learnblockchain.cn/docs/foundry/i18n/zh 

## 安装
  https://getfoundry.sh 

## 创建新项目
 `forge init  project_name` 
**项目结构**：
• cache : forge 缓存信息，在 forge build 后出现
• lib ：存放依赖库(默认安装 forge-std）
• out：存放编译输出文件
• script：合约脚本，可用于部署合约、广播交易
• src: 合约源代码
• test: 测试合约代码
• foundry.toml : 项目 foundy 配置
## 依赖项
`forge install 依赖项名称`

**重映射依赖项**
```
在 foundry.toml 中设置重映射
remappings = [
    "@solmate-utils/=lib/solmate/src/utils/",
]
现在我们可以像这样导入 solmate repo的 src/utils 中的任何合约：

import {LibString} from "@solmate-utils/LibString.sol";
```
**更新依赖项**
`forge update lib/solmate 或者forge update一次对所有依赖项执行更  新。`
**删除依赖项**
` forge remove solmate 等同于 forge remove lib/solmate `
## 编译
`forge build`

## 合约部署

**forge create 部署**
```
forge create Counter --private-key 
0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://localhost:8545
--broadcast
```

**forge script 部署**
```
forge script script/Counter.s.sol --private-key 
0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7b f4f2ff80 --rpc-url http://localhost:8545 --broadcast
```
--rpc_url 默认为：http://localhost:8545 如果只是模拟执⾏，去掉 --broadcast

**也可以创建一个.env 文件，将所有配置都写进入**
```
# 区块链 RPC 节点地址
LOCAL_RPC_URL=http://127.0.0.1:8545
SEPOLIA_RPC_URL=xxxx
# 钱包私钥，注意需要以0x开头，在你的私钥前面加上0x就行
PRIVATE_KEY=xxxx
# 区块链浏览器的 API KEY TOKEN
ETHERSCAN_API_KEY=xxxx
```
然后在 foundry.toml 文件中配置
```
[rpc_endpoints]
local = "{LOCAL_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"


```
然后通过如下命令部署合约
```
source .env

forge create Counter --private-key $PRIVATE_KEY --rpc-url $SEPOLIA_RPC_URL --broadcast
```
**在代码中加载账号**

 ![image](.\image.png)

部署合约：forge script .\script\Counter.s.sol --rpc-url local --broadcast

**开源合约代码**
在 etherscan 浏览器申请⼀个 key:https://etherscan.io/myaccount
foundry.toml 配置
```
[etherscan]
sepolia = { key = "${ETHERSCAN_API_KEY}" }
```
部署合约：forge script .\script\Counter.s.sol --rpc-url sepolia --broadcast --verify

部署未开源，后面再开源：
```
forge verify-contract \
    0x98dFd785d9f0083797D2708791DF77f41843F594 \
    src/MyERC20.sol:MyERC20 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "OpenSpace S6" "OS6") \
    --verifier etherscan \
    --verifier-url https://api-sepolia.etherscan.io/api \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --chain-id 11155111
```
## Cast
**cast钱包创建、导入和keystore存储**
```
 cast wallet -h # 查看所有的命令选项
 cast wallet new [DIR] <ACCOUNT_NAME> # Create a new random keypair
 cast wallet new-mnemonic  #  mnemonic phrase
 cast wallet address [PRIVATE_KEY]  # private key to an address
 cast wallet import -i -k <KEYSTORE_DIR> <ACCOUNT_NAME>
 cast wallet import --mnemonic "test test test test test test test test test test test junk” -k <KEYSTORE_DIR> <ACCOUNT_NAME>
```
**使用keystore部署合约**
```
forge create Counter --keystore .keys/wallet1 --rpc-url http://localhost:8545 --broadcast
```
**合约交互**
```
cast balance <address>   查看余额
cast send  toAddr --value 1ether --private-key <private-key> 转账
cast call <address> “number()” 查看erc20余额
cast abi-encode "constructor(string,string)" "OpenSpace S6"“OS6” abi参数编码
其它：https://book.getfoundry.sh/reference/cast/
```
## anvil
允许开发者在本地环境中运行一个轻量级的以太坊节点。要启动 Anvil，只需在命令行中输入 anvil，它将自动启动一个本地节点。启动后，你将看到一系列已生成的开发账户和私钥，以及节点侦听的地址和端口信息。

输出将包括多个开发账户、私钥以及监听的端口。
![image](.\image-1.png)

```
anvil 启动模拟本地以太坊节点
anvil --fork-url <RPC_RUL>  加载其它网络的状态到本地模拟环境
anvil --hardfork <HARDFORK>  硬分叉版本
anvil -p, --port <PORT>  指定启动的端口号
```

## 测试
**基本用法**
首先需要导入forge-std/Test.sol库，并让测试合约继承自Test：
```
pragma solidity 0.8.10;

import "forge-std/Test.sol";

contract MyTest is Test {
    // 测试代码
}
```
这样，测试合约就可以访问Test合约提供的断言方法、日志功能和 cheatcodes 等。
**setUp函数**
setUp是一个可选函数，会在每个测试用例运行前被调用，用于初始化测试环境：
```
function setUp() public {
    // 初始化代码
}
```
**test函数**

以test为前缀的函数会被识别为测试用例并执行：
```
function test_MyFunctionality() public {
    // 断言和测试逻辑
}
```
**testFail函数**
与test前缀相反，testFail用于标识一个预期失败的测试。如果该函数没有触发revert，则测试失败：
```
function testFail_MyFailingCase() public {
    // 预期失败的测试逻辑
}
```
**共享设置**
通过创建抽象合约并在测试合约中继承它们，可以实现设置的共享：
```
abstract contract SetupHelper {
    // 共享的设置代码
}

contract MyTest is Test, SetupHelper {
    function setUp() public {
        // 使用共享设置
    }
}
```
写完测试代码后，直接输入命令测试
```
forge test -vvv

v 越多，显⽰的测试报告越详细
• -vv: 增加显⽰测试过程中的⽇志
• -vvv：增加显⽰失败测试的堆栈跟踪
• -vvvv: 显⽰所有测试的堆栈跟踪，并显⽰失败测试的setup跟踪
• -vvvvv: 始终显⽰堆栈跟踪和设置跟踪
```
 **Gas 报告**
 ```
forge test —gas-report
forge test test/Counter.t.sol --fuzz-runs 2000 -vv --gas-report
 ```
![image](.\image-2.png)

为Gas消耗生成一个快照文件(默认为 .gas-snapshot)
```
forge snapshot 
forge snapshot --snap <FILE_NAME>
```
代码修改后，不同的 .gas-snapshot 对比 gas 消耗：
```
forge snapshot --diff .gas-snap2 // 当前运行的snap 与 gas-snap2 对比
forge snapshot --check .gas-snap2 // 对比并显示不同
```
**console.log()**

Console.log 最多支持 4 个参数、4 个类型：uint、string、bool、address
支持打印格式化内容: %s, %d console.log("Changing owner from %s to %s", currentOwner, newOwner
在测试网、主网上执行时，无效，但会消耗 gas

**合约测试作弊码**
⽤于在测试中模拟各种场景和条件，作弊码分以下几类，[链接]( https://getfoundry.sh/reference/cheatcodes/overview)：
• Environment（环境）：改变 EVM 状态的作弊码。
• Asser tions（断言）：断言作弊码。
• Fuzzer（模糊测试器）：配置模糊测试器的作弊码。
• External（外部）：与外部状态（文件、命令等）交互的作弊码。
• Utilities（实用工具）：实用工具作弊码。
• Forking（分叉）：分叉模式的作弊码。
• Snapshots（快照）：快照作弊码。
• RPC：与 RPC 相关的作弊码。
• File（文件）：处理文件的作弊码。

**常用作弊码**
```
vm.roll(uint256 blockNumber)：模拟区块号的变更。
vm.warp(uint256 timestamp)：改变区块时间戳。
vm.prank(address sender)：更改下一个调用的发送者（msg.sender）。
vm.deal(address to, uint256 amount)：重置ETH余额到指定地址。
deal(address token, address to, uint256 amount)：重置ERC20代币余额。
```
**断言合约执行错误**
vm.expectRevert允许我们指定一个特定的错误类型或信息，然后执行可能触发该错误的操作。如果合约按预期报错，则测试通过。
```
error NotOwner(address caller);
 function transferOwnership2(address newOwner) public {
 if (msg.sender != owner) revert NotOwner(msg.sender);
 owner = newOwner;
 }
 function test_Revert_IFNOT_Owner2() public {
 vm.startPrank(alice);
 Owner o = new Owner();
 vm.stopPrank();
 vm.startPrank(bob);
 bytes memory data = abi.encodeWithSignature("NotOwner(address)", bob);
 vm.expectRevert(data); // 预期下一条语句会revert
 o.transferOwnership2(alice);
 vm.stopPrank();
 }
// forge test test/Cheatcode.t.sol --mt test_Revert_IFNOT_Owner2 -vv
```
**断⾔合约事件**

vm.expectEmit 在测试中验证特定事件是否被正确触发及其参数是否符合预期，对于确保合约行为的正确性至关重要。vm.expectEmit允许我们预先指定期望的事件特征，并验证合约操作中是否触发了相应的事件。
```
event OwnerTransfer(address indexed caller, address indexed newOwner);
 function transferOwnership(address newOwner) public {
 require(msg.sender == owner, "Only the owner can transfer ownership");
 owner = newOwner;
 emit OwnerTransfer(msg.sender, newOwner);
 }
 function test_Emit() public {
 Owner o = new Owner();
 vm.expectEmit(true, true, false, false);
 emit OwnerTransfer(address(this), bob);
 o.transferOwnership(bob);
 }
// forge test test/Cheatcode.t.sol --mt test_Emit -vv
```
**分杈测试**
当需要与线上现有合约进行交互时，分叉测试特别有用。每个分叉是一个独立的EVM，在分叉的快照之上有独立的存储，分杈有两种方法: 分叉模式和分叉作弊码。
**分杈模式**
```
forge test --fork-url <your_rpc_url> --fork-block-number 1
forge test test/Counter.t.sol --fork-url <your_rpc_url> -vv
```
如果需要从特定区块开始分叉，可以使用--fork-block-number 标志：
```
forge test --fork-url <your_rpc_url> --fork-block-number 100
```
**分杈作弊码**
使用vm.createFork方法创建不同分杈，通过vm.selectFork方法，我们选择并激活一个特定的分叉，然后通过vm.activeFork()验证当前激活的分叉是否正确。
```
function setUp() public {
 uint forkBlock = 8219000;
 sepoliaForkId = vm.createSelectFork(vm.rpcUrl("sepolia"), forkBlock);
 }
 function test_Something() public {
 vm.selectFork(sepoliaForkId);
 assertEq(vm.activeFork(), sepoliaForkId);
 MyERC20 token = MyERC20(0x21b4D1f6d42dc6083db848D42AA4b6895371E1e7);
 assertGe(token.balanceOf(0xe74c813e3f545122e88A72FB1dF94052F93B808f), 1e18);
 }
// forge test test/Fork.t.sol --mt test_Something -vv
```

**模糊（Fuzz）测试**
模糊（Fuzz）测试通过自动生成大量随机输入数据来测试程序,如下随机输⼊ to 和 about 测试转账的健壮性
vm.assume 设置条件， bound 设置取值范围。
```
function testFuzz_ERC20Transfer(address to, uint256 amount) public {
 vm.assume(to != address(0));
 vm.assume(to != address(this));
 amount = bound(amount, 0, 10000 * 10 ** 18);
 // vm.assume(amount <= token.balanceOf(address(this)));
 
 token.transfer(to, amount);
 assertEq(token.balanceOf(to), amount);
 }
```
 **不变性测试**
 用于验证智能合约在任何随机的调用序列和模糊输入下，都满足特定的条件保持不变。
• 如所有⽤户 ERC20 余额的总和等于总供应量， AMM 总是 K = x*y
• 在函数名称前加上 invariant 来表示不变量测试
• 使用 targetContract 和 targetSelector 来指定要测试的合约和函数

比如对如下MyERC20合约，设计不变量：总额等于所有账户余额之和
```
contract MyERC20Test is Test {
    MyERC20 public token;
    address[] public users;
    
    function setUp() public {
        token = new MyERC20("MyToken", "MTK");
        // console.log("New MyERC20 instance:", address(token));
        
        // 创建一些测试用户
        for (uint i = 1; i <= 10; i++) {
            address user = address(uint160(i));
            users.push(user);
            // 为每个用户分配1000个代币
            token.transfer(user, 1000 * 10 ** 18);
        }
        users.push(address(this));
        
        // 配置不变性测试的目标合约
        targetContract(address(this));
        // targetSelector(address(token), "transfer(address,uint256)");

    }
    
    // 这个函数会被 Foundry 随机调用
    function transfer(uint256 fromIndex, uint256 toIndex, uint256 amount) public {
        // 确保索引在有效范围内
        fromIndex = fromIndex % users.length;
        toIndex = toIndex % users.length;
        
        // 确保不是同一个用户
        vm.assume(fromIndex != toIndex);
        
        // 获取发送者和接收者地址
        address from = users[fromIndex];
        address to = users[toIndex];
        
        // 确保发送者有足够的余额
        uint256 fromBalance = token.balanceOf(from);
        amount = amount % (fromBalance + 1);
        
        // 执行转账
        vm.prank(from);
        token.transfer(to, amount);
    }
    
    // 在很多随机调用transfer后， 验证总供应量等于所有用户余额的总和
    function invariant_totalSupplyEqualsSumOfBalances() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 sumOfBalances = 0;
        
        // 计算所有用户余额的总和
        console.log("users.length", users.length);
        for (uint i = 0; i < users.length; i++) {
            sumOfBalances += token.balanceOf(users[i]);
        }
        
        // 验证总供应量等于所有用户余额的总和
        assertEq(totalSupply, sumOfBalances, "Total supply does not equal the sum of all user balances");
    }
    
} 
```















































