//+------------------------------------------------------------------+
//| Input parameters                                                |
//+------------------------------------------------------------------+
input double StartCapital = 20.0; // Starting capital in USD
input double RiskPercentage = 2.0; // Risk percentage per trade (e.g., 2%)
input double TakeProfitMultiplier = 2.0; // Take profit multiplier (e.g., 2x ATR)
input double TrailingDistanceMultiplier = 1.0; // Trailing distance multiplier (e.g., 1x ATR)
input double TotalProfitTarget = 20.0; // Total profit target in USD
input double ATRThreshold = 100.0; // ATR threshold for crash detection
input double ExtremeATRThreshold = 150.0; // ATR extreme threshold for forced exit
input double MaxPriceDropPercentage = 2.0; // Maximum allowed BTC/USD drop in 5 min before forced exit
input int MaxTradeDuration = 1800; // Maximum trade duration in seconds (e.g., 30 minutes)
input double MinLotSize = 0.01; // Minimum lot size
input int RSIPeriod = 12; // RSI period
input double RSIOverbought = 75; // RSI overbought level
input double RSIOversold = 25; // RSI oversold level
input int ADXPeriod = 12; // ADX period
input double ADXThreshold = 20; // ADX threshold for strong trend
input double MinSL = 20; // Minimum stop-loss in points
input double MinTP = 40; // Minimum take-profit in points
input double MinFreeMarginPercent = 20.0; // Minimum free margin percentage to allow trading
input double MinimumCapitalProtection = 10.0; // Minimum capital you want to protect

//+------------------------------------------------------------------+
//| Include CTrade class for trade operations                        |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if account balance is below minimum capital protection
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if (accountBalance < MinimumCapitalProtection)
   {
      Print("Balance below minimum protection level. Stopping trades.");
      return;  // Exit the function and stop opening new trades
   }

   double lotSize = CalculateLotSize(); // Dynamic position sizing

   // Monitor Margin Levels
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginLevel = (freeMargin / accountBalance) * 100;

   Print("Balance: ", accountBalance, " | Free Margin: ", freeMargin, " | Margin Level: ", marginLevel, "%");

   // Stop trading if free margin is too low
   if (marginLevel < MinFreeMarginPercent)
   {
      Print("Low Margin Warning: Free margin below ", MinFreeMarginPercent, "%. Stopping new trades.");
      return;
   }

   // Calculate cumulative profit
   double cumulativeProfit = 0;
   for (int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket))
      {
         cumulativeProfit += PositionGetDouble(POSITION_PROFIT);
      }
   }

   // Stop trading if cumulative profit reaches the target
   if (cumulativeProfit >= TotalProfitTarget)
   {
      Print("Target reached: Stopping trading.");
      return;
   }

   // Calculate indicators
   double fastMA[], slowMA[], atr[], rsi[], adx[];
   int fastMA_handle = iMA(_Symbol, PERIOD_M5, 5, 0, MODE_SMA, PRICE_CLOSE);
   int slowMA_handle = iMA(_Symbol, PERIOD_M5, 20, 0, MODE_SMA, PRICE_CLOSE);
   int atr_handle = iATR(_Symbol, PERIOD_M5, 14);
   int rsi_handle = iRSI(_Symbol, PERIOD_M5, RSIPeriod, PRICE_CLOSE);
   int adx_handle = iADX(_Symbol, PERIOD_M5, ADXPeriod);

   CopyBuffer(fastMA_handle, 0, 0, 2, fastMA);
   CopyBuffer(slowMA_handle, 0, 0, 2, slowMA);
   CopyBuffer(atr_handle, 0, 0, 1, atr);
   CopyBuffer(rsi_handle, 0, 0, 1, rsi);
   CopyBuffer(adx_handle, 0, 0, 1, adx);

   double currentFastMA = fastMA[0];
   double currentSlowMA = slowMA[0];
   double currentATR = atr[0];
   double currentRSI = rsi[0];
   double currentADX = adx[0];
   double lastClosePrice = iClose(_Symbol, PERIOD_M5, 1);
   double previousClosePrice = iClose(_Symbol, PERIOD_M5, 2);
   double priceDropPercentage = ((previousClosePrice - lastClosePrice) / previousClosePrice) * 100;

   Print("Fast MA: ", currentFastMA, " | Slow MA: ", currentSlowMA, " | ATR: ", currentATR, " | RSI: ", currentRSI, " | ADX: ", currentADX);

   // Adjust lot size based on ATR
   if (currentATR > ATRThreshold)
   {
      lotSize *= 0.5;  // Reduce lot size by 50% in high volatility conditions
      lotSize = MathMax(lotSize, MinLotSize);  // Ensure it doesn't go below MinLotSize
   }

   // Prevent trading if ATR is extremely high
   if (currentATR > ExtremeATRThreshold)
   {
      Print("Extreme Volatility Detected (ATR > ", ExtremeATRThreshold, "). No new trades allowed.");
      return;
   }

   // Emergency Exit: Close all trades if ATR exceeds extreme threshold or price drops significantly
   if (currentATR > ExtremeATRThreshold || priceDropPercentage > MaxPriceDropPercentage)
   {
      Print("Extreme Crash Detected! Closing all trades.");
      CloseAllTrades();
   }

   // Check if there are open positions
   if (PositionsTotal() == 0)
   {
      if ((currentFastMA - currentSlowMA) > 5 && currentRSI < RSIOverbought && currentADX > ADXThreshold)
      {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         trade.Buy(lotSize, _Symbol, ask, 0, ask + (TakeProfitMultiplier * currentATR));
      }
      else if ((currentFastMA - currentSlowMA) < -5 && currentRSI > RSIOversold && currentADX > ADXThreshold)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         trade.Sell(lotSize, _Symbol, bid, 0, bid - (TakeProfitMultiplier * currentATR));
      }
   }

   // Smart Time-Based Exit: Close trades after MaxTradeDuration if in loss or breakeven
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket))
      {
         // Fixed the casting issue from long to datetime
         datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);  // Cast long to datetime
         double positionProfit = PositionGetDouble(POSITION_PROFIT);
         
         if ((TimeCurrent() - openTime >= MaxTradeDuration) && (positionProfit <= 0))
         {
            // Close trade if it's in loss or breakeven after MaxTradeDuration
            Print("Max trade duration reached. Closing trade.");
            trade.PositionClose(ticket);
         }
         else if (currentADX < ADXThreshold)
         {
            // Close trade early if ADX shows a weak trend
            Print("Weak trend detected (ADX < ", ADXThreshold, "). Closing trade.");
            trade.PositionClose(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close all open trades                                           |
//+------------------------------------------------------------------+
void CloseAllTrades()
{
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket))
      {
         trade.PositionClose(ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                 |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double riskAmount = StartCapital * (RiskPercentage / 100);
   double lotSize = riskAmount / 10;
   lotSize = lotSize * (100 / iATR(_Symbol, PERIOD_M5, 14));
   lotSize = MathMax(lotSize, MinLotSize);
   lotSize = MathMin(lotSize, 0.1);
   return lotSize;
}
