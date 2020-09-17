//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input double Lot=0.01;
input double TP=60.0;
input double SL=100.0;
input int Period1=200;
input int Period2=20;
input int Period3=5;
input int MagicNumber=1111;

bool flagBeginOrder= false;
int bar=-1;
double factor=1;
int trend=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   flagBeginOrder = false;
   if(Digits==3 || Digits==5)
      factor=10.0;
   else
      factor=1.0;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(bar==Bars)
      return;
   bar=Bars;



   double fast_ma=iMA(Symbol(),PERIOD_CURRENT,Period2,0,MODE_EMA,PRICE_CLOSE,1);
   double slow_ma=iMA(Symbol(),PERIOD_CURRENT,Period1,0,MODE_EMA,PRICE_CLOSE,1);
   double very_fast_ma=iMA(Symbol(),PERIOD_CURRENT,Period3,0,MODE_EMA,PRICE_CLOSE,1);

   double StopLoss=NormalizeDouble((SL*factor*Point),Digits);
   double TakeProfit=NormalizeDouble((TP*factor*Point),Digits);

   TakeProfit();

   if(fast_ma>slow_ma && (trend==-1 || trend==2))
     {
      //StopAll();
      trend=1;
      if(!flagBeginOrder)
        {
         flagBeginOrder = true;
         return;
        }
      StopAll();
      int ticket = OrderSend(Symbol(),OP_BUY,Lot,Ask,5,0,0,"Roengrit : BUY Order",MagicNumber,0,clrGreen);

     }
   else
      if(fast_ma<slow_ma && (trend==-1 || trend==1))
        {
         //
         trend=2;
         if(!flagBeginOrder)
           {
            flagBeginOrder = true;
            return;
           }
         StopAll();
         int ticket = OrderSend(Symbol(),OP_SELL,Lot,Bid,5,0,0,"Roengrit : SELL Order",MagicNumber,0,clrOrange);
        }
      else
        {
         //Do nothing
        }

   if(trend==1)
      Comment("UP TREND");
   else
      if(trend==2)
         Comment("DOWN TREND");
      else
         Comment("WAITING FOR TREND");
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TakeProfit()
  {
   double StopLoss=NormalizeDouble((SL*factor*Point),Digits);
   double TakeProfit=NormalizeDouble((TP*factor*Point),Digits);

   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      int tk = OrderSelect(i, SELECT_BY_POS);
      double profit =  OrderProfit();
      double st = OrderStopLoss();
      if(profit>0)
        {
         //double d = Bars-0.300;
         int orType = OrderType();
         if(orType == OP_BUY)
           {
            if(st < (Ask - StopLoss) || st == 0)
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask - StopLoss,0,0,clrNONE))
                 {
                  Print("Order ", OrderTicket()," openprice : ", OrderOpenPrice()," stop : ", Ask - StopLoss," current : ", Ask, " failed to modify. Error: ", GetLastError());
                 }
           }
         if(orType == OP_SELL)
           {
            double StopLossLoc = NormalizeDouble(((SL+50)*factor*Point),Digits);
            if(st > (Ask + StopLossLoc) || st == 0)
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask + StopLossLoc,0,0,clrNONE))
                 {
                  Print("Order ", OrderTicket()," openprice : ", OrderOpenPrice()," stop : ", Ask + StopLossLoc," current : ", Ask, " failed to modify. Error: ", GetLastError());
                 }
           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StopAll()
  {
   int total = OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      int tk = OrderSelect(i, SELECT_BY_POS);
      double profit =  OrderProfit();
      if(profit >= -2)
        {
         continue;
        }
      string comment = OrderComment();
      if(comment != "Roengrit : SELL Order" && comment != "Roengrit : BUY Order")
        {
         continue;
        }

      int type   = OrderType();

      bool result = false;

      switch(type)
        {
         //Close opened long positions
         case OP_BUY       :
            result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
            break;

         //Close opened short positions
         case OP_SELL      :
            result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);

        }

      if(result == false)
        {
         Print("Order ", OrderTicket(), " failed to close. Error:", GetLastError());
         Sleep(0);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
