https://docs.microsoft.com/ja-jp/azure/devops/pipelines/release/approvals/gates?WT.mc_id=msignitethetour-github-dev20&view=azure-devops
の翻訳

https://github.com/MicrosoftDocs/vsts-docs/blob/master/docs/pipelines/release/approvals/gates.md

----
---
title: Control deployments by using gates
---

# ゲートを使ったリリース時のデプロイ制御

**Azure Pipelines**

ゲート機能は、外部サービスからの正常性信号を自動収集し、
すべての信号が同時に成功した場合にリリースを進めるか、
タイムアウト時の展開を取りやめることが可能です。
通常、ゲートはインシデント管理、問題管理に関連して使用されます。
例として、変更管理、監視、および外部承認システムが挙げられます。

## ゲートのシナリオ

ゲートのシナリオとユース ケースには、次の例があります。

- **インシデントと問題管理** : 作業項目、インシデント、および懸案事項に必要なステータスを確認します。たとえば、優先度 0 のバグが存在しない場合にのみ展開が行われ、展開後にアクティブなインシデントが存在しないことを確認します。
- **Azure パイプライン**の外部で承認を求める : Azure Pipeline 以外のユーザー (法的承認部門、監査担当者、IT 管理者など) に対して、Microsoft Teams や Slack などの承認コラボレーション システムと統合し、承認が完了するのを待つことで、展開について通知します。
- **品質検証** : 合格率やコード カバレッジなどのビルド アーティファクトのテストからメトリックを照会し、必要なしきい値内にある場合にのみデプロイします。
- **アーティファクトのセキュリティスキャン** : ウイルス対策チェック、コード署名、ビルド成果物のポリシー チェックなどのセキュリティ スキャンが完了していることを確認します。ゲートがスキャンを開始して完了するのを待つか、完了を確認するだけです。
- **ベースライン**に対するユーザーエクスペリエンス : 製品テレメトリを使用して、ユーザー エクスペリエンスがベースライン状態からリグレッションされていないことを確認します。展開前のエクスペリエンス レベルは、ベースラインと見なされます。
- **変更管理** : ServiceNow などのシステムの変更管理手順が完了してから、展開が実行されます。
- **インフラの健全性** : 導入後に監視を実行し、コンプライアンス ルールに照らしてインフラストラクチャを検証するか、正常なリソース使用率と肯定的なセキュリティ レポートを待ちます。

健康パラメータのほとんどは時間の経過とともに変化し、定期的に状態を正常から不健康に変更し、健康に戻ります。
このようなバリエーションを考慮して、すべてのゲートが同時に成功するまで、すべてのゲートが定期的に再評価されます。
すべてのゲートが同じ間隔で、構成されたタイムアウトの前に成功しない場合、リリースの実行と展開は続行されません。

## ステージのゲートを定義する

ステージの開始時にゲートを有効にすることができます(**展開前条件**)。
またはステージの終わりに (**展開後の条件**)、またはその両方。
ゲートを有効にする方法の詳細については、[ゲートの設定](..)を参照してください。

**評価前の遅延**はゲート評価の開始時の時間遅延です
ゲートが初期化し、安定化し、正確な結果を提供し始めるプロセス
現在のデプロイについては([ゲート評価フロー](#eval例)を参照)。例えば：

- **展開前ゲート**の場合、遅延はすべてのバグがログに記録されるのに必要な時間になります。
展開されるアーティファクトに対して。
- **展開後のゲート**の場合、遅延はデプロイされたアプリに要する時間の最大値になります。
安定した運用状態に達するためには、必要なすべてのテストの実行に要する時間
展開されたステージ、および展開後にインシデントがログに記録されるまでにかかる時間。

既定では、次のゲートを使用できます。

- **Azure Functions を呼び出す**: Azure Functionsの実行をトリガーし、正常に完了することを確認します。
詳細については、[Azure Functions task](..)を参照してください。
- **クエリ Azure モニターアラート**: アクティブなアラートの構成済み Azure モニター アラート ルールに従います。
詳細については、[Azure monitor task](../../tasks/utility/azure-monitor.md).を参照してください。
- **REST API**を呼び出す: REST API を呼び出し、正常な応答を返した場合に続行します。
詳細については、[HTTP REST API task](../../tasks/utility/http-rest-api.md).
- **クエリ作業項目**: クエリから返される一致する作業項目の数がしきい値内にあることを確認します。
詳細については、 [Work item query task](../../tasks/utility/work-item-query.md).を参照してください。
- **セキュリティとコンプライアンス評価**: の範囲内のリソースに対する Azure ポリシーのコンプライアンスを評価する
サブスクリプションとリソース グループを指定し、必要に応じて特定のリソース レベルで指定します。詳細については、
  [Security Compliance and Assessment task](../../tasks/utility/azure-policy.md).

- マーケットプレイス拡張で自身のGatesも作ることができます。
   
追加したすべてのゲートに適用される評価オプションは次のとおりです。
- **ゲートの再評価までの時間**。連続する評価の間の時間間隔。
サンプリング間隔ごとに、新しい要求が各ゲートに同時に送信されます。
新しい結果が評価されます。サンプリング間隔が最も長い間隔より大きい方が推奨されます。
すべての応答を評価のために受信する時間を確保するために、設定されたゲートの一般的な応答時間。
- **ゲートが失敗した後のタイムアウト**。すべてのゲートの最大評価期間。
すべてのゲートが同じサンプリング間隔で成功する前にタイムアウトに達すると、展開は拒否されます。
- **ゲートと承認**。両方を設定している場合は、ゲートと承認に必要な実行順序を選択します。
展開前の条件では、既定では、最初に手動 (ユーザー) の承認を求めるプロンプトを表示し、その後ゲートを評価します。
これにより、リリースがユーザによって拒否された場合、システムはゲート機能の評価を受けなくなります。
展開後の条件では、デフォルトでは、すべてのゲートが成功した場合にのみゲートを評価し、手動で承認を求めます。
これにより、承認者はサインオフに必要なすべての情報を確実に取得できます。


ゲートの結果とログの表示については、
[View the logs for approvals](../deploy-using-approvals.md#view-approvals) と
[Monitor and track deployments](../define-multistage-release-process.md#monitor-track)を参照してください

<a name="eval-examples"></a>

### ゲート評価フローの例

次の図は、ゲート評価の流れを示しています。
初期安定化遅延期間と3つのサンプリング間隔により、展開が承認されます。

![Successful gates](_img/gate-results-pass.png)

次の図は、ゲート評価の流れを示しています。
最初の安定化遅延期間は、すべてのゲートが各サンプリング間隔で成功したわけではありません。インチ
この場合、タイムアウト期間が終了すると、展開は拒否されます。

![Failed gates](_img/gate-results-fail.png)

## 関連する項目

- [Approvals and gates overview](index.md)
- [Manual intervention](../deploy-using-approvals.md#configure-maninter)
- [Use approvals and gates to control your deployment](../../release/deploy-using-approvals.md)
- [Security Compliance and Assessment task](../../tasks/utility/azure-policy.md)
- [Stages](../../process/stages.md)
- [Triggers](../triggers.md)

## こちらも確認

- [Video: Deploy quicker and safer with gates in Azure Pipelines](https://channel9.msdn.com/Events/Connect/2017/T181)
- [Configure your release pipelines for safe deployments](https://blogs.msdn.microsoft.com/visualstudioalm/2017/04/24/configuring-your-release-pipelines-for-safe-deployments/)
- [Tutorial: Use approvals and gates to control your deployment](../deploy-using-approvals.md)
- [Twitter sentiment as a release gate](https://blogs.msdn.microsoft.com/bharry/2017/12/15/twitter-sentiment-as-a-release-gate/)
- [GitHub issues as a release gate](https://www.visualstudiogeeks.com/DevOps/github-issues-as-deployment-gate-in-vsts-rm)
- [Author custom gates](https://github.com/Microsoft/azure-pipelines-tasks/blob/master/docs/authoring/gates.md). [Library with examples](https://github.com/Microsoft/vsts-rm-extensions/tree/master/ServerTaskHelper/DistributedTask.ServerTask.Remote.Common) 

[!INCLUDE [rm-help-support-shared](../../_shared/rm-help-support-shared.md)]

## ビデオ
- [!VIDEO https://www.youtube.com/embed/7WLcqwhTZ_4?start=0]
