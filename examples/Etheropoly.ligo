type constructor_args is record
  tokenContract_ : address;
end;

type tokenFallback_args is record
  from_ : address;
  value_ : nat;
  data_ : bytes;
end;

type constructor_args is unit;
type myTokens_args is unit;
type myDividends_args is record
  includeReferralBonus_ : bool;
end;

type totalEthereumBalance_args is unit;
type buy_args is record
  referredBy_ : address;
end;

type fallback_args is unit;
type payCharity_args is unit;
type reinvest_args is unit;
type sell_args is record
  amountOfTokens_ : nat;
end;

type withdraw_args is unit;
type exit_args is unit;
type transfer_args is record
  toAddress_ : address;
  amountOfTokens_ : nat;
end;

type transferAndCall_args is record
  to_ : address;
  value_ : nat;
  data_ : bytes;
end;

type disableInitialStage_args is unit;
type setAdministrator_args is record
  identifier_ : address;
  status_ : bool;
end;

type setStakingRequirement_args is record
  amountOfTokens_ : nat;
end;

type setCanAcceptTokens_args is record
  address_ : address;
  value_ : bool;
end;

type setName_args is record
  name_ : string;
end;

type setSymbol_args is record
  symbol_ : string;
end;

type totalSupply_args is unit;
type balanceOf_args is record
  customerAddress_ : address;
end;

type dividendsOf_args is record
  customerAddress_ : address;
end;

type sellPrice_args is unit;
type buyPrice_args is unit;
type calculateTokensReceived_args is record
  ethereumToSpend_ : nat;
end;

type calculateEthereumReceived_args is record
  tokensToSell_ : nat;
end;

type etherToSendCharity_args is unit;
type constructor_args is record
  tokenContract_ : address;
end;

type tokenFallback_args is record
  from_ : address;
  value_ : nat;
  data_ : bytes;
end;

type constructor_args is unit;
type myTokens_args is unit;
type myDividends_args is record
  includeReferralBonus_ : bool;
end;

type totalEthereumBalance_args is unit;
type buy_args is record
  referredBy_ : address;
end;

type fallback_args is unit;
type payCharity_args is unit;
type reinvest_args is unit;
type sell_args is record
  amountOfTokens_ : nat;
end;

type withdraw_args is unit;
type exit_args is unit;
type transfer_args is record
  toAddress_ : address;
  amountOfTokens_ : nat;
end;

type transferAndCall_args is record
  to_ : address;
  value_ : nat;
  data_ : bytes;
end;

type disableInitialStage_args is unit;
type setAdministrator_args is record
  identifier_ : address;
  status_ : bool;
end;

type setStakingRequirement_args is record
  amountOfTokens_ : nat;
end;

type setCanAcceptTokens_args is record
  address_ : address;
  value_ : bool;
end;

type setName_args is record
  name_ : string;
end;

type setSymbol_args is record
  symbol_ : string;
end;

type totalSupply_args is unit;
type balanceOf_args is record
  customerAddress_ : address;
end;

type dividendsOf_args is record
  customerAddress_ : address;
end;

type sellPrice_args is unit;
type buyPrice_args is unit;
type calculateTokensReceived_args is record
  ethereumToSpend_ : nat;
end;

type calculateEthereumReceived_args is record
  tokensToSell_ : nat;
end;

type etherToSendCharity_args is unit;
type state is record
  tokenContract : acceptsEtheropoly_Etheropoly;
  name : string;
  symbol : string;
  decimals : nat;
  dividendFee_ : nat;
  charityFee_ : nat;
  tokenPriceInitial_ : nat;
  tokenPriceIncremental_ : nat;
  magnitude : nat;
  giveEthCharityAddress : address;
  totalEthCharityRecieved : nat;
  totalEthCharityCollected : nat;
  stakingRequirement : nat;
  ambassadors_ : map(address, bool);
  ambassadorMaxPurchase_ : nat;
  ambassadorQuota_ : nat;
  tokenBalanceLedger_ : map(address, nat);
  referralBalance_ : map(address, nat);
  payoutsTo_ : map(address, int);
  ambassadorAccumulatedQuota_ : map(address, nat);
  tokenSupply_ : nat;
  profitPerShare_ : nat;
  administrators : map(address, bool);
  onlyAmbassadors : bool;
  canAcceptTokens_ : map(address, bool);
end;

type router_enum is
  | Constructor of constructor_args
  | TokenFallback of tokenFallback_args
  | Constructor of constructor_args
  | MyTokens of myTokens_args
  | MyDividends of myDividends_args
  | TotalEthereumBalance of totalEthereumBalance_args
  | Buy of buy_args
  | Fallback of fallback_args
  | PayCharity of payCharity_args
  | Reinvest of reinvest_args
  | Sell of sell_args
  | Withdraw of withdraw_args
  | Exit of exit_args
  | Transfer of transfer_args
  | TransferAndCall of transferAndCall_args
  | DisableInitialStage of disableInitialStage_args
  | SetAdministrator of setAdministrator_args
  | SetStakingRequirement of setStakingRequirement_args
  | SetCanAcceptTokens of setCanAcceptTokens_args
  | SetName of setName_args
  | SetSymbol of setSymbol_args
  | TotalSupply of totalSupply_args
  | BalanceOf of balanceOf_args
  | DividendsOf of dividendsOf_args
  | SellPrice of sellPrice_args
  | BuyPrice of buyPrice_args
  | CalculateTokensReceived of calculateTokensReceived_args
  | CalculateEthereumReceived of calculateEthereumReceived_args
  | EtherToSendCharity of etherToSendCharity_args;

(* modifier onlyTokenContract inlined *)

function constructor (const self : state; const tokenContract_ : address) : (list(operation) * state) is
  block {
    self.tokenContract := (* LIGO unsupported *)etheropoly(self, tokenContract_);
  } with ((nil: list(operation)), self);

function tokenFallback (const self : state; const from_ : address; const value_ : nat; const data_ : bytes) : (list(operation) * state * bool) is
  block {
    skip
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self, match_action.tokenContract_)
  | TokenFallback(match_action) -> tokenFallback(self, match_action.from_, match_action.value_, match_action.data_)
  | Constructor(match_action) -> constructor(self)
  | MyTokens(match_action) -> (myTokens(self), self)
  | MyDividends(match_action) -> (myDividends(self, match_action.includeReferralBonus_), self)
  | TotalEthereumBalance(match_action) -> (totalEthereumBalance(self), self)
  | Buy(match_action) -> buy(self, match_action.referredBy_)
  | Fallback(match_action) -> fallback(self)
  | PayCharity(match_action) -> payCharity(self)
  | Reinvest(match_action) -> reinvest(self)
  | Sell(match_action) -> sell(self, match_action.amountOfTokens_)
  | Withdraw(match_action) -> 
  | Exit(match_action) -> exit(self)
  | Transfer(match_action) -> transfer(self, match_action.toAddress_, match_action.amountOfTokens_)
  | TransferAndCall(match_action) -> transferAndCall(self, match_action.to_, match_action.value_, match_action.data_)
  | DisableInitialStage(match_action) -> disableInitialStage(self)
  | SetAdministrator(match_action) -> setAdministrator(self, match_action.identifier_, match_action.status_)
  | SetStakingRequirement(match_action) -> setStakingRequirement(self, match_action.amountOfTokens_)
  | SetCanAcceptTokens(match_action) -> setCanAcceptTokens(self, match_action.address_, match_action.value_)
  | SetName(match_action) -> setName(self, match_action.name_)
  | SetSymbol(match_action) -> setSymbol(self, match_action.symbol_)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.customerAddress_), self)
  | DividendsOf(match_action) -> (dividendsOf(self, match_action.customerAddress_), self)
  | SellPrice(match_action) -> (sellPrice(self), self)
  | BuyPrice(match_action) -> (buyPrice(self), self)
  | CalculateTokensReceived(match_action) -> (calculateTokensReceived(self, match_action.ethereumToSpend_), self)
  | CalculateEthereumReceived(match_action) -> (calculateEthereumReceived(self, match_action.tokensToSell_), self)
  | EtherToSendCharity(match_action) -> (etherToSendCharity(self), self)
  end);
type router_enum is
  | Constructor of constructor_args
  | TokenFallback of tokenFallback_args
  | Constructor of constructor_args
  | MyTokens of myTokens_args
  | MyDividends of myDividends_args
  | TotalEthereumBalance of totalEthereumBalance_args
  | Buy of buy_args
  | Fallback of fallback_args
  | PayCharity of payCharity_args
  | Reinvest of reinvest_args
  | Sell of sell_args
  | Withdraw of withdraw_args
  | Exit of exit_args
  | Transfer of transfer_args
  | TransferAndCall of transferAndCall_args
  | DisableInitialStage of disableInitialStage_args
  | SetAdministrator of setAdministrator_args
  | SetStakingRequirement of setStakingRequirement_args
  | SetCanAcceptTokens of setCanAcceptTokens_args
  | SetName of setName_args
  | SetSymbol of setSymbol_args
  | TotalSupply of totalSupply_args
  | BalanceOf of balanceOf_args
  | DividendsOf of dividendsOf_args
  | SellPrice of sellPrice_args
  | BuyPrice of buyPrice_args
  | CalculateTokensReceived of calculateTokensReceived_args
  | CalculateEthereumReceived of calculateEthereumReceived_args
  | EtherToSendCharity of etherToSendCharity_args;

(* modifier onlyBagholders inlined *)

(* modifier onlyStronghands inlined *)

(* modifier notContract inlined *)

(* modifier onlyAdministrator inlined *)

(* modifier antiEarlyWhale inlined *)

(* EventDefinition onTokenPurchase(customerAddress : address; incomingEthereum : nat; tokensMinted : nat; referredBy : address) *)

(* EventDefinition onTokenSell(customerAddress : address; tokensBurned : nat; ethereumEarned : nat) *)

(* EventDefinition onReinvestment(customerAddress : address; ethereumReinvested : nat; tokensMinted : nat) *)

(* EventDefinition onWithdraw(customerAddress : address; ethereumWithdrawn : nat) *)

(* EventDefinition Transfer(from : address; res__to : address; tokens : nat) *)

function constructor (const self : state) : (list(operation) * state) is
  block {
    self.administrators[0x85abE8E3bed0d4891ba201Af1e212FE50bb65a26] := True;
    self.ambassadors_[0x85abE8E3bed0d4891ba201Af1e212FE50bb65a26] := True;
    self.ambassadors_[0x87A7e71D145187eE9aAdc86954d39cf0e9446751] := True;
    self.ambassadors_[0x11756491343b18cb3db47e9734f20096b4f64234] := True;
    self.ambassadors_[0x4ffE17a2A72bC7422CB176bC71c04EE6D87cE329] := True;
    self.ambassadors_[0xfE8D614431E5fea2329B05839f29B553b1Cb99A2] := True;
  } with ((nil: list(operation)), self);

function myTokens (const self : state) : (list(operation) * nat) is
  block {
    const customerAddress_ : address = sender;
  } with ((nil: list(operation)));

function myDividends (const self : state; const includeReferralBonus_ : bool) : (list(operation) * nat) is
  block {
    const customerAddress_ : address = sender;
  } with ((nil: list(operation)));

function totalEthereumBalance (const self : state) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function sqrt (const x : nat) : (nat) is
  block {
    const y : nat = 0n;
    const z : nat = ((x + 1n) / 2n);
    y := x;
    while (z < y) block {
      y := z;
      z := (((x / z) + z) / 2n);
    };
  } with (y);

function ethereumToTokens_ (const self : state; const ethereum_ : nat) : (nat) is
  block {
    const tokenPriceInitial_ : nat = (self.tokenPriceInitial_ * 1e18n);
    const tokensReceived_ : nat = abs((safeMath.sub(sqrt(((((self.tokenPriceInitial_ LIGO_IMPLEMENT_ME_PLEASE_POW 2n) + ((2n * (self.tokenPriceIncremental_ * 1e18n)) * (ethereum_ * 1e18n))) + ((self.tokenPriceIncremental_ LIGO_IMPLEMENT_ME_PLEASE_POW 2n) * (self.tokenSupply_ LIGO_IMPLEMENT_ME_PLEASE_POW 2n))) + (((2n * self.tokenPriceIncremental_) * self.tokenPriceInitial_) * self.tokenSupply_))), self.tokenPriceInitial_) / self.tokenPriceIncremental_) - self.tokenSupply_);
  } with (tokensReceived_);

function purchaseTokens (const self : state; const incomingEthereum_ : nat; const referredBy_ : address) : (state * nat) is
  block {
    const amountOfEthereum_ : nat = incomingEthereum_;
    const customerAddress_ : address = sender;
    if (self.onlyAmbassadors and ((totalEthereumBalance(self) - amountOfEthereum_) <= self.ambassadorQuota_)) then block {
      assert((bitwise_not(bitwise_xor((case self.ambassadors_[customerAddress_] of | None -> False | Some(x) -> x end), True)) and (((case self.ambassadorAccumulatedQuota_[customerAddress_] of | None -> 0n | Some(x) -> x end) + amountOfEthereum_) <= self.ambassadorMaxPurchase_)));
      self.ambassadorAccumulatedQuota_[customerAddress_] := safeMath.add((case self.ambassadorAccumulatedQuota_[customerAddress_] of | None -> 0n | Some(x) -> x end), amountOfEthereum_);
      const undividedDividends_ : nat = safeMath.div(safeMath.mul(incomingEthereum_, self.dividendFee_), 100n);
      const referralBonus_ : nat = safeMath.div(undividedDividends_, 3n);
      const charityPayout_ : nat = safeMath.div(safeMath.mul(incomingEthereum_, self.charityFee_), 100n);
      const dividends_ : nat = safeMath.sub(undividedDividends_, referralBonus_);
      const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(incomingEthereum_, undividedDividends_), charityPayout_);
      self.totalEthCharityCollected := safeMath.add(self.totalEthCharityCollected, charityPayout_);
      const amountOfTokens_ : nat = ethereumToTokens_(self, taxedEthereum_);
      const fee_ : nat = (dividends_ * self.magnitude);
      assert(((amountOfTokens_ > 0n) and (safeMath.add(amountOfTokens_, self.tokenSupply_) > self.tokenSupply_)));
      if (((referredBy_ =/= 0x0000000000000000000000000000000000000000) and (referredBy_ =/= sender)) and ((case self.tokenBalanceLedger_[referredBy_] of | None -> 0n | Some(x) -> x end) >= self.stakingRequirement)) then block {
        self.referralBalance_[referredBy_] := safeMath.add((case self.referralBalance_[referredBy_] of | None -> 0n | Some(x) -> x end), referralBonus_);
      } else block {
        dividends_ := safeMath.add(dividends_, referralBonus_);
        fee_ := (dividends_ * self.magnitude);
      };
      if (self.tokenSupply_ > 0n) then block {
        self.tokenSupply_ := safeMath.add(self.tokenSupply_, amountOfTokens_);
        self.profitPerShare_ := (self.profitPerShare_ + ((dividends_ * self.magnitude) / self.tokenSupply_));
        fee_ := abs(fee_ - abs(fee_ - (amountOfTokens_ * ((dividends_ * self.magnitude) / self.tokenSupply_))));
      } else block {
        self.tokenSupply_ := amountOfTokens_;
      };
      self.tokenBalanceLedger_[sender] := safeMath.add((case self.tokenBalanceLedger_[sender] of | None -> 0n | Some(x) -> x end), amountOfTokens_);
      const updatedPayouts_ : int = int(abs(abs((self.profitPerShare_ * amountOfTokens_) - fee_)));
      self.payoutsTo_[sender] := ((case self.payoutsTo_[sender] of | None -> 0 | Some(x) -> x end) + updatedPayouts_);
      (* EmitStatement onTokenPurchase(sender, _incomingEthereum, _amountOfTokens, _referredBy) *)
    } else block {
      self.onlyAmbassadors := False;
      const undividedDividends_ : nat = safeMath.div(safeMath.mul(incomingEthereum_, self.dividendFee_), 100n);
      const referralBonus_ : nat = safeMath.div(undividedDividends_, 3n);
      const charityPayout_ : nat = safeMath.div(safeMath.mul(incomingEthereum_, self.charityFee_), 100n);
      const dividends_ : nat = safeMath.sub(undividedDividends_, referralBonus_);
      const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(incomingEthereum_, undividedDividends_), charityPayout_);
      self.totalEthCharityCollected := safeMath.add(self.totalEthCharityCollected, charityPayout_);
      const amountOfTokens_ : nat = ethereumToTokens_(self, taxedEthereum_);
      const fee_ : nat = (dividends_ * self.magnitude);
      assert(((amountOfTokens_ > 0n) and (safeMath.add(amountOfTokens_, self.tokenSupply_) > self.tokenSupply_)));
      if (((referredBy_ =/= 0x0000000000000000000000000000000000000000) and (referredBy_ =/= sender)) and ((case self.tokenBalanceLedger_[referredBy_] of | None -> 0n | Some(x) -> x end) >= self.stakingRequirement)) then block {
        self.referralBalance_[referredBy_] := safeMath.add((case self.referralBalance_[referredBy_] of | None -> 0n | Some(x) -> x end), referralBonus_);
      } else block {
        dividends_ := safeMath.add(dividends_, referralBonus_);
        fee_ := (dividends_ * self.magnitude);
      };
      if (self.tokenSupply_ > 0n) then block {
        self.tokenSupply_ := safeMath.add(self.tokenSupply_, amountOfTokens_);
        self.profitPerShare_ := (self.profitPerShare_ + ((dividends_ * self.magnitude) / self.tokenSupply_));
        fee_ := abs(fee_ - abs(fee_ - (amountOfTokens_ * ((dividends_ * self.magnitude) / self.tokenSupply_))));
      } else block {
        self.tokenSupply_ := amountOfTokens_;
      };
      self.tokenBalanceLedger_[sender] := safeMath.add((case self.tokenBalanceLedger_[sender] of | None -> 0n | Some(x) -> x end), amountOfTokens_);
      const updatedPayouts_ : int = int(abs(abs((self.profitPerShare_ * amountOfTokens_) - fee_)));
      self.payoutsTo_[sender] := ((case self.payoutsTo_[sender] of | None -> 0 | Some(x) -> x end) + updatedPayouts_);
      (* EmitStatement onTokenPurchase(sender, _incomingEthereum, _amountOfTokens, _referredBy) *)
    };
  } with (self);

function purchaseInternal (const self : state; const incomingEthereum_ : nat; const referredBy_ : address) : (state * nat) is
  block {
    assert((sender = source));
    const purchaseEthereum : nat = incomingEthereum_;
    const excess : nat = 0n;
    if (purchaseEthereum > (5n * 1000000n)) then block {
      if (safeMath.sub(self_address.res__balance, purchaseEthereum) <= (100n * 1000000n)) then block {
        purchaseEthereum := (5n * 1000000n);
        excess := safeMath.sub(incomingEthereum_, purchaseEthereum);
      } else block {
        skip
      };
    } else block {
      skip
    };
    purchaseTokens(self, purchaseEthereum, referredBy_);
    if (excess > 0n) then block {
      var opList : list(operation) := list transaction(unit, excess * 1mutez, (get_contract(sender) : contract(unit))) end;
    } else block {
      skip
    };
  } with (self);

function buy (const self : state; const referredBy_ : address) : (list(operation) * state * nat) is
  block {
    purchaseInternal(self, (amount / 1mutez), referredBy_);
  } with ((nil: list(operation)), self);

function fallback (const self : state) : (list(operation) * state) is
  block {
    purchaseInternal(self, (amount / 1mutez), 0x0);
  } with ((nil: list(operation)), self);

function payCharity (const self : state) : (list(operation) * state) is
  block {
    const ethToPay : nat = safeMath.sub(self.totalEthCharityCollected, self.totalEthCharityRecieved);
    assert((ethToPay > 1n));
    self.totalEthCharityRecieved := safeMath.add(self.totalEthCharityRecieved, ethToPay);
    if (not (self.giveEthCharityAddress.call.value(self, ethToPay).gas(self, 400000)(self))) then block {
      self.totalEthCharityRecieved := safeMath.sub(self.totalEthCharityRecieved, ethToPay);
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function reinvest (const self : state) : (list(operation) * state) is
  block {
    assert((myDividends(self, True) > 0));
    const dividends_ : nat = myDividends(self, False);
    const customerAddress_ : address = sender;
    self.payoutsTo_[customerAddress_] := ((case self.payoutsTo_[customerAddress_] of | None -> 0 | Some(x) -> x end) + int(abs((dividends_ * self.magnitude))));
    dividends_ := (dividends_ + (case self.referralBalance_[customerAddress_] of | None -> 0n | Some(x) -> x end));
    self.referralBalance_[customerAddress_] := 0n;
    const tokens_ : nat = purchaseTokens(self, dividends_, 0x0);
    (* EmitStatement onReinvestment(_customerAddress, _dividends, _tokens) *)
  } with ((nil: list(operation)), self);

function tokensToEthereum_ (const self : state; const tokens_ : nat) : (nat) is
  block {
    const tokens_ : nat = (tokens_ + 1e18n);
    const tokenSupply_ : nat = (self.tokenSupply_ + 1e18n);
    const etherReceived_ : nat = (safeMath.sub((abs((self.tokenPriceInitial_ + (self.tokenPriceIncremental_ * (self.tokenSupply_ / 1e18n))) - self.tokenPriceIncremental_) * (tokens_ - 1e18n)), ((self.tokenPriceIncremental_ * (abs((tokens_ LIGO_IMPLEMENT_ME_PLEASE_POW 2n) - tokens_) / 1e18n)) / 2n)) / 1e18n);
  } with (etherReceived_);

function sell (const self : state; const amountOfTokens_ : nat) : (list(operation) * state) is
  block {
    assert((myTokens(self) > 0));
    const customerAddress_ : address = sender;
    assert((amountOfTokens_ <= (case self.tokenBalanceLedger_[customerAddress_] of | None -> 0n | Some(x) -> x end)));
    const tokens_ : nat = amountOfTokens_;
    const ethereum_ : nat = tokensToEthereum_(self, tokens_);
    const dividends_ : nat = safeMath.div(safeMath.mul(ethereum_, self.dividendFee_), 100n);
    const charityPayout_ : nat = safeMath.div(safeMath.mul(ethereum_, self.charityFee_), 100n);
    const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(ethereum_, dividends_), charityPayout_);
    self.totalEthCharityCollected := safeMath.add(self.totalEthCharityCollected, charityPayout_);
    self.tokenSupply_ := safeMath.sub(self.tokenSupply_, tokens_);
    self.tokenBalanceLedger_[customerAddress_] := safeMath.sub((case self.tokenBalanceLedger_[customerAddress_] of | None -> 0n | Some(x) -> x end), tokens_);
    const updatedPayouts_ : int = int(abs(((self.profitPerShare_ * tokens_) + (taxedEthereum_ * self.magnitude))));
    self.payoutsTo_[customerAddress_] := ((case self.payoutsTo_[customerAddress_] of | None -> 0 | Some(x) -> x end) - updatedPayouts_);
    if (self.tokenSupply_ > 0n) then block {
      self.profitPerShare_ := safeMath.add(self.profitPerShare_, ((dividends_ * self.magnitude) / self.tokenSupply_));
    } else block {
      skip
    };
    (* EmitStatement onTokenSell(_customerAddress, _tokens, _taxedEthereum) *)
  } with ((nil: list(operation)), self);

function withdraw (const self : state) : (list(operation) * state) is
  block {
    assert((myDividends(self, True) > 0));
    const customerAddress_ : address = sender;
    const dividends_ : nat = myDividends(self, False);
    self.payoutsTo_[customerAddress_] := ((case self.payoutsTo_[customerAddress_] of | None -> 0 | Some(x) -> x end) + int(abs((dividends_ * self.magnitude))));
    dividends_ := (dividends_ + (case self.referralBalance_[customerAddress_] of | None -> 0n | Some(x) -> x end));
    self.referralBalance_[customerAddress_] := 0n;
    var opList : list(operation) := list transaction(unit, dividends_ * 1mutez, (get_contract(customerAddress_) : contract(unit))) end;
    (* EmitStatement onWithdraw(_customerAddress, _dividends) *)
  } with (opList, self);

function exit (const self : state) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    const tokens_ : nat = (case self.tokenBalanceLedger_[customerAddress_] of | None -> 0n | Some(x) -> x end);
    if (tokens_ > 0n) then block {
      sell(self, tokens_);
    } else block {
      skip
    };
    withdraw(self);
  } with ((nil: list(operation)), self);

function transfer (const self : state; const toAddress_ : address; const amountOfTokens_ : nat) : (list(operation) * state * bool) is
  block {
    assert((myTokens(self) > 0));
    const customerAddress_ : address = sender;
    assert((amountOfTokens_ <= (case self.tokenBalanceLedger_[customerAddress_] of | None -> 0n | Some(x) -> x end)));
    if (myDividends(self, True) > 0) then block {
      skip
    } withdraw(self); else block {
      skip
    };
    self.tokenBalanceLedger_[customerAddress_] := safeMath.sub((case self.tokenBalanceLedger_[customerAddress_] of | None -> 0n | Some(x) -> x end), amountOfTokens_);
    self.tokenBalanceLedger_[toAddress_] := safeMath.add((case self.tokenBalanceLedger_[toAddress_] of | None -> 0n | Some(x) -> x end), amountOfTokens_);
    self.payoutsTo_[customerAddress_] := ((case self.payoutsTo_[customerAddress_] of | None -> 0 | Some(x) -> x end) - int(abs((self.profitPerShare_ * amountOfTokens_))));
    self.payoutsTo_[toAddress_] := ((case self.payoutsTo_[toAddress_] of | None -> 0 | Some(x) -> x end) + int(abs((self.profitPerShare_ * amountOfTokens_))));
    (* EmitStatement Transfer(_customerAddress, _toAddress, _amountOfTokens) *)
  } with ((nil: list(operation)), self);

function isContract (const self : state; const addr_ : address) : (bool) is
  block {
    const is_contract : bool = False;
    const length : nat = 0n;
    (* InlineAssembly {
        length := extcodesize(_addr)
    } *)
  } with ((length > 0n));

function transferAndCall (const self : state; const to_ : address; const value_ : nat; const data_ : bytes) : (list(operation) * state * bool) is
  block {
    assert((to_ =/= ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address)));
    assert(bitwise_not(bitwise_xor((case self.canAcceptTokens_[to_] of | None -> False | Some(x) -> x end), True)));
    assert(transfer(self, to_, value_));
    if (isContract(self, to_)) then block {
      const receiver : UNKNOWN_TYPE_AcceptsEtheropoly = (* LIGO unsupported *)acceptsEtheropoly(self, to_);
      assert(receiver.tokenFallback(self, sender, value_, data_));
    } else block {
      skip
    };
  } with ((nil: list(operation)), self);

function disableInitialStage (const self : state) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.onlyAmbassadors := False;
  } with ((nil: list(operation)), self);

function setAdministrator (const self : state; const identifier_ : address; const status_ : bool) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.administrators[identifier_] := status_;
  } with ((nil: list(operation)), self);

function setStakingRequirement (const self : state; const amountOfTokens_ : nat) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.stakingRequirement := amountOfTokens_;
  } with ((nil: list(operation)), self);

function setCanAcceptTokens (const self : state; const address_ : address; const value_ : bool) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.canAcceptTokens_[address_] := value_;
  } with ((nil: list(operation)), self);

function setName (const self : state; const name_ : string) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.name := name_;
  } with ((nil: list(operation)), self);

function setSymbol (const self : state; const symbol_ : string) : (list(operation) * state) is
  block {
    const customerAddress_ : address = sender;
    assert((case self.administrators[customerAddress_] of | None -> False | Some(x) -> x end));
    self.symbol := symbol_;
  } with ((nil: list(operation)), self);

function totalSupply (const self : state) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function balanceOf (const self : state; const customerAddress_ : address) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function dividendsOf (const self : state; const customerAddress_ : address) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function sellPrice (const self : state) : (list(operation) * nat) is
  block {
    if (self.tokenSupply_ = 0n) then block {
      skip
    } with ((nil: list(operation))); else block {
      const ethereum_ : nat = tokensToEthereum_(self, 1e18);
      const dividends_ : nat = safeMath.div(safeMath.mul(ethereum_, self.dividendFee_), 100n);
      const charityPayout_ : nat = safeMath.div(safeMath.mul(ethereum_, self.charityFee_), 100n);
      const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(ethereum_, dividends_), charityPayout_);
    } with ((nil: list(operation)));;
  } with ((nil: list(operation)));

function buyPrice (const self : state) : (list(operation) * nat) is
  block {
    if (self.tokenSupply_ = 0n) then block {
      skip
    } with ((nil: list(operation))); else block {
      const ethereum_ : nat = tokensToEthereum_(self, 1e18);
      const dividends_ : nat = safeMath.div(safeMath.mul(ethereum_, self.dividendFee_), 100n);
      const charityPayout_ : nat = safeMath.div(safeMath.mul(ethereum_, self.charityFee_), 100n);
      const taxedEthereum_ : nat = safeMath.add(safeMath.add(ethereum_, dividends_), charityPayout_);
    } with ((nil: list(operation)));;
  } with ((nil: list(operation)));

function calculateTokensReceived (const self : state; const ethereumToSpend_ : nat) : (list(operation) * nat) is
  block {
    const dividends_ : nat = safeMath.div(safeMath.mul(ethereumToSpend_, self.dividendFee_), 100n);
    const charityPayout_ : nat = safeMath.div(safeMath.mul(ethereumToSpend_, self.charityFee_), 100n);
    const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(ethereumToSpend_, dividends_), charityPayout_);
    const amountOfTokens_ : nat = ethereumToTokens_(self, taxedEthereum_);
  } with ((nil: list(operation)));

function calculateEthereumReceived (const self : state; const tokensToSell_ : nat) : (list(operation) * nat) is
  block {
    assert((tokensToSell_ <= self.tokenSupply_));
    const ethereum_ : nat = tokensToEthereum_(self, tokensToSell_);
    const dividends_ : nat = safeMath.div(safeMath.mul(ethereum_, self.dividendFee_), 100n);
    const charityPayout_ : nat = safeMath.div(safeMath.mul(ethereum_, self.charityFee_), 100n);
    const taxedEthereum_ : nat = safeMath.sub(safeMath.sub(ethereum_, dividends_), charityPayout_);
  } with ((nil: list(operation)));

function etherToSendCharity (const self : state) : (list(operation) * nat) is
  block {
    skip
  } with ((nil: list(operation)));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self, match_action.tokenContract_)
  | TokenFallback(match_action) -> tokenFallback(self, match_action.from_, match_action.value_, match_action.data_)
  | Constructor(match_action) -> constructor(self)
  | MyTokens(match_action) -> (myTokens(self), self)
  | MyDividends(match_action) -> (myDividends(self, match_action.includeReferralBonus_), self)
  | TotalEthereumBalance(match_action) -> (totalEthereumBalance(self), self)
  | Buy(match_action) -> buy(self, match_action.referredBy_)
  | Fallback(match_action) -> fallback(self)
  | PayCharity(match_action) -> payCharity(self)
  | Reinvest(match_action) -> reinvest(self)
  | Sell(match_action) -> sell(self, match_action.amountOfTokens_)
  | Withdraw(match_action) -> 
  | Exit(match_action) -> exit(self)
  | Transfer(match_action) -> transfer(self, match_action.toAddress_, match_action.amountOfTokens_)
  | TransferAndCall(match_action) -> transferAndCall(self, match_action.to_, match_action.value_, match_action.data_)
  | DisableInitialStage(match_action) -> disableInitialStage(self)
  | SetAdministrator(match_action) -> setAdministrator(self, match_action.identifier_, match_action.status_)
  | SetStakingRequirement(match_action) -> setStakingRequirement(self, match_action.amountOfTokens_)
  | SetCanAcceptTokens(match_action) -> setCanAcceptTokens(self, match_action.address_, match_action.value_)
  | SetName(match_action) -> setName(self, match_action.name_)
  | SetSymbol(match_action) -> setSymbol(self, match_action.symbol_)
  | TotalSupply(match_action) -> (totalSupply(self), self)
  | BalanceOf(match_action) -> (balanceOf(self, match_action.customerAddress_), self)
  | DividendsOf(match_action) -> (dividendsOf(self, match_action.customerAddress_), self)
  | SellPrice(match_action) -> (sellPrice(self), self)
  | BuyPrice(match_action) -> (buyPrice(self), self)
  | CalculateTokensReceived(match_action) -> (calculateTokensReceived(self, match_action.ethereumToSpend_), self)
  | CalculateEthereumReceived(match_action) -> (calculateEthereumReceived(self, match_action.tokensToSell_), self)
  | EtherToSendCharity(match_action) -> (etherToSendCharity(self), self)
  end);
function safeMath_mul (const a : nat; const b : nat) : (nat) is
  block {
    if (a = 0n) then block {
      skip
    } with (0n); else block {
      skip
    };
    const c : nat = (a * b);
    assert(((c / a) = b));
  } with (c);

function safeMath_div (const a : nat; const b : nat) : (nat) is
  block {
    const c : nat = (a / b);
  } with (c);

function safeMath_sub (const a : nat; const b : nat) : (nat) is
  block {
    assert((b <= a));
  } with (abs(a - b));

function safeMath_add (const a : nat; const b : nat) : (nat) is
  block {
    const c : nat = (a + b);
    assert((c >= a));
  } with (c);
