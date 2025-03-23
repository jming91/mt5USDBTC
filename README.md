# BTC/USD Trading Bot for MetaTrader 5 (MT5)

This is an automated trading bot for BTC/USD on MetaTrader 5 (MT5) that utilizes advanced risk management, market analysis, and volatility protection to trade Bitcoin against the US Dollar. The bot aims to balance profitability with risk control and capital preservation.

## Features
- **Dynamic Position Sizing**: Adjusts trade size based on a percentage of your account balance and market volatility (ATR).
- **Capital Protection**: Stops trading if the account balance falls below a defined minimum threshold.
- **Risk Management**: Trades with a fixed risk percentage per trade (e.g., 2%) and employs trailing stops and take-profit based on market conditions.
- **Market Indicators**: Uses moving averages (MA), RSI, ADX, and ATR to analyze the market and trigger trades.
- **Crash Protection**: Stops new trades and exits positions during extreme volatility or market crashes.
- **Time-Based Exit**: Automatically closes trades after a set duration if they don’t reach a favorable outcome.
- **Cumulative Profit Target**: Stops trading once a cumulative profit target (e.g., $20) is reached.

---

## Instructions for Using the BTC/USD Trading Bot

### Step 1: Preparing MetaTrader 5 (MT5)
1. **Download and Install MetaTrader 5 (MT5)**: Install MT5 from your broker's website or [MetaTrader's official site](https://www.metatrader5.com/).
2. **Log in to Your Account**: Open MT5 and log in with your account credentials.
3. **Ensure BTC/USD is Available**: Make sure BTC/USD is listed and available for trading.

### Step 2: Loading the Bot on MetaTrader 5
1. **Open MetaEditor**: In MT5, go to **Tools > MetaEditor** or press `F4`.
2. **Create a New Expert Advisor (EA)**: Go to **File > New > Expert Advisor**. Name it (e.g., "BTCUSD_Trading_Bot") and click **Finish**.
3. **Copy and Paste the Code**: Copy the bot code and paste it into the new EA file in MetaEditor.
4. **Compile the Bot**: Press `F7` to compile. Ensure there are no errors or warnings in the **Errors** tab.

### Step 3: Setting Up the Bot for Trading
1. **Attach the Bot to a Chart**: 
   - Open the BTC/USD chart in MT5.
   - In the **Navigator** panel, find your EA (e.g., "BTCUSD_Trading_Bot") and drag it onto the chart.
2. **Configure the Bot Inputs**:
   - Set parameters like **StartCapital**, **RiskPercentage**, **TakeProfitMultiplier**, **ATRThreshold**, etc., to customize the bot's behavior.
3. **Enable Auto-Trading**: 
   - Ensure **AutoTrading** is enabled in the MT5 toolbar (green button).

### Step 4: Monitoring the Bot’s Performance
1. **Check the Expert Advisor**: Monitor the bot’s activity in the **Experts** and **Journal** tabs of the **Terminal** window.
2. **Adjust Settings**: If needed, right-click the chart, go to **Expert Advisors > Properties**, and modify settings.

### Step 5: Stopping the Bot
1. **Disable Auto-Trading**: Disable **AutoTrading** by clicking the button in the toolbar (red when disabled).
2. **Remove the Expert Advisor**: Right-click the chart and select **Expert Advisors > Remove** to stop the bot.

---

## Important Notes
- **Risk Management**: Ensure you understand the risk percentage per trade to control potential losses.
- **Monitoring**: Though the bot operates autonomously, monitor its performance, especially during volatile market conditions.
- **Customization**: Modify parameters in the code for more control over its behavior.

---

By following these steps, you can use the BTC/USD Trading Bot on MetaTrader 5 to trade Bitcoin while managing risk and optimizing profits.

Happy trading!

--- 
