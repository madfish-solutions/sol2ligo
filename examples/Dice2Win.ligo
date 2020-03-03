FLAG need_prevent_deploy
type dice2Win_Bet is record
  res__amount : nat;
  modulo : nat;
  rollUnder : nat;
  placeBlockNumber : nat;
  mask : nat;
  gambler : address;
end;

type constructor_args is unit;
type approveNextOwner_args is record
  nextOwner_ : address;
end;

type acceptNextOwner_args is unit;
type fallback_args is unit;
type setSecretSigner_args is record
  newSecretSigner : address;
end;

type setCroupier_args is record
  newCroupier : address;
end;

type setMaxProfit_args is record
  maxProfit_ : nat;
end;

type increaseJackpot_args is record
  increaseAmount : nat;
end;

type withdrawFunds_args is record
  beneficiary : address;
  withdrawAmount : nat;
end;

type kill_args is unit;
type placeBet_args is record
  betMask : nat;
  modulo : nat;
  commitLastBlock : nat;
  commit : nat;
  r : bytes;
  s : bytes;
end;

type settleBet_args is record
  reveal : nat;
  blockHash : bytes;
end;

type settleBetUncleMerkleProof_args is record
  reveal : nat;
  canonicalBlockNumber : nat;
end;

type refundBet_args is record
  commit : nat;
end;

type state is record
  HOUSE_EDGE_PERCENT : nat;
  HOUSE_EDGE_MINIMUM_AMOUNT : nat;
  MIN_JACKPOT_BET : nat;
  JACKPOT_MODULO : nat;
  JACKPOT_FEE : nat;
  MIN_BET : nat;
  MAX_AMOUNT : nat;
  MAX_MODULO : nat;
  MAX_MASK_MODULO : nat;
  MAX_BET_MASK : nat;
  BET_EXPIRATION_BLOCKS : nat;
  DUMMY_ADDRESS : address;
  owner : address;
  nextOwner : address;
  maxProfit : nat;
  secretSigner : address;
  jackpotSize : nat;
  lockedInBets : nat;
  bets : map(nat, dice2Win_Bet);
  croupier : address;
  POPCNT_MULT : nat;
  POPCNT_MASK : nat;
  POPCNT_MODULO : nat;
end;

const dice2Win_Bet_default : dice2Win_Bet = record [ amount = 0n;
	modulo = 0n;
	rollUnder = 0n;
	placeBlockNumber = 0n;
	mask = 0n;
	gambler = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address) ];

type router_enum is
  | Constructor of constructor_args
  | ApproveNextOwner of approveNextOwner_args
  | AcceptNextOwner of acceptNextOwner_args
  | Fallback of fallback_args
  | SetSecretSigner of setSecretSigner_args
  | SetCroupier of setCroupier_args
  | SetMaxProfit of setMaxProfit_args
  | IncreaseJackpot of increaseJackpot_args
  | WithdrawFunds of withdrawFunds_args
  | Kill of kill_args
  | PlaceBet of placeBet_args
  | SettleBet of settleBet_args
  | SettleBetUncleMerkleProof of settleBetUncleMerkleProof_args
  | RefundBet of refundBet_args;

(* EventDefinition FailedPayment(beneficiary : address; res__amount : nat) *)

(* EventDefinition Payment(beneficiary : address; res__amount : nat) *)

(* EventDefinition JackpotPayment(beneficiary : address; res__amount : nat) *)

(* EventDefinition Commit(commit : nat) *)

(* modifier onlyOwner inlined *)

(* modifier onlyCroupier inlined *)

function constructor (const self : state) : (list(operation) * state) is
  block {
    self.owner := sender;
    self.secretSigner := self.DUMMY_ADDRESS;
    self.croupier := self.DUMMY_ADDRESS;
  } with ((nil: list(operation)), self);

function approveNextOwner (const self : state; const nextOwner_ : address) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    assert((nextOwner_ =/= self.owner)) (* "Cannot approve current owner." *);
    self.nextOwner := nextOwner_;
  } with ((nil: list(operation)), self);

function acceptNextOwner (const self : state) : (list(operation) * state) is
  block {
    assert((sender = self.nextOwner)) (* "Can only accept preapproved new owner." *);
    self.owner := self.nextOwner;
  } with ((nil: list(operation)), self);

function fallback (const self : state) : (list(operation) * state) is
  block {
    skip
  } with ((nil: list(operation)), self);

function setSecretSigner (const self : state; const newSecretSigner : address) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    self.secretSigner := newSecretSigner;
  } with ((nil: list(operation)), self);

function setCroupier (const self : state; const newCroupier : address) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    self.croupier := newCroupier;
  } with ((nil: list(operation)), self);

function setMaxProfit (const self : state; const maxProfit_ : nat) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    assert((maxProfit_ < self.MAX_AMOUNT)) (* "maxProfit should be a sane number." *);
    self.maxProfit := maxProfit_;
  } with ((nil: list(operation)), self);

function increaseJackpot (const self : state; const increaseAmount : nat) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    assert((increaseAmount <= self_address.res__balance)) (* "Increase amount larger than balance." *);
    assert((((self.jackpotSize + self.lockedInBets) + increaseAmount) <= self_address.res__balance)) (* "Not enough funds." *);
    self.jackpotSize := (self.jackpotSize + abs(increaseAmount));
  } with ((nil: list(operation)), self);

function sendFunds (const self : state; const beneficiary : address; const res__amount : nat; const successLogAmount : nat) : (list(operation) * state) is
  block {
    if (var opList : list(operation) := list transaction(unit, res__amount * 1mutez, (get_contract(beneficiary) : contract(unit))) end) then block {
      (* EmitStatement undefined(beneficiary, successLogAmount) *)
    } else block {
      (* EmitStatement undefined(beneficiary, amount) *)
    };
  } with ((nil: list(operation)), self);

function withdrawFunds (const self : state; const beneficiary : address; const withdrawAmount : nat) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    assert((withdrawAmount <= self_address.res__balance)) (* "Increase amount larger than balance." *);
    assert((((self.jackpotSize + self.lockedInBets) + withdrawAmount) <= self_address.res__balance)) (* "Not enough funds." *);
    sendFunds(self, beneficiary, withdrawAmount, withdrawAmount);
  } with ((nil: list(operation)), self);

function kill (const self : state) : (list(operation) * state) is
  block {
    assert((sender = self.owner)) (* "OnlyOwner methods called by non-owner." *);
    assert((self.lockedInBets = 0n)) (* "All bets should be processed (settled or refunded) before self-destruct." *);
    selfdestruct(self.owner);
  } with ((nil: list(operation)), self);

function getDiceWinAmount (const amount : nat; const modulo : nat; const rollUnder : nat) : ((nat * nat)) is
  block {
    const winAmount : nat = 0n;
    const jackpotFee : nat = 0n;
    assert(((0n < rollUnder) and (rollUnder <= modulo))) (* "Win probability out of range." *);
    jackpotFee := (case (res__amount >= self.MIN_JACKPOT_BET) of | True -> self.JACKPOT_FEE | False -> 0n end);
    const houseEdge : nat = ((res__amount * self.HOUSE_EDGE_PERCENT) / 100n);
    if (houseEdge < self.HOUSE_EDGE_MINIMUM_AMOUNT) then block {
      houseEdge := self.HOUSE_EDGE_MINIMUM_AMOUNT;
    } else block {
      skip
    };
    assert(((houseEdge + jackpotFee) <= res__amount)) (* "Bet doesn't even cover house edge." *);
    winAmount := ((abs(abs(res__amount - houseEdge) - jackpotFee) * modulo) / rollUnder);
  } with ((winAmount, jackpotFee));

function placeBet (const self : state; const betMask : nat; const modulo : nat; const commitLastBlock : nat; const commit : nat; const r : bytes; const s : bytes) : (list(operation) * state) is
  block {
    const bet : dice2Win_Bet = (case self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
    assert((bet.gambler = ("tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg" : address))) (* "Bet should be in a 'clean' state." *);
    const res__amount : nat = (amount / 1mutez);
    assert(((modulo > 1n) and (modulo <= self.MAX_MODULO))) (* "Modulo should be within range." *);
    assert(((res__amount >= self.MIN_BET) and (res__amount <= self.MAX_AMOUNT))) (* "Amount should be within range." *);
    assert(((betMask > 0n) and (betMask < self.MAX_BET_MASK))) (* "Mask should be within range." *);
    assert((0n <= commitLastBlock)) (* "Commit has expired." *);
    const signatureHash : bytes = sha_256((abs(commitLastBlock), commit));
    assert((self.secretSigner = ecrecover(signatureHash, 27n, r, s))) (* "ECDSA signature is not valid." *);
    const rollUnder : nat = 0n;
    const mask : nat = 0n;
    if (modulo <= self.MAX_MASK_MODULO) then block {
      rollUnder := (bitwise_and((betMask * self.POPCNT_MULT), self.POPCNT_MASK) mod self.POPCNT_MODULO);
      mask := betMask;
    } else block {
      assert(((betMask > 0n) and (betMask <= modulo))) (* "High modulo range, betMask larger than modulo." *);
      rollUnder := betMask;
    };
    const possibleWinAmount : nat = 0n;
    const jackpotFee : nat = 0n;
    (possibleWinAmount, jackpotFee) := getDiceWinAmount(res__amount, modulo, rollUnder);
    assert((possibleWinAmount <= (res__amount + self.maxProfit))) (* "maxProfit limit violation." *);
    self.lockedInBets := (self.lockedInBets + abs(possibleWinAmount));
    self.jackpotSize := (self.jackpotSize + abs(jackpotFee));
    assert(((self.jackpotSize + self.lockedInBets) <= self_address.res__balance)) (* "Cannot afford to lose this bet." *);
    (* EmitStatement undefined(commit) *)
    bet.res__amount := res__amount;
    bet.modulo := abs(modulo);
    bet.rollUnder := abs(rollUnder);
    bet.placeBlockNumber := abs(0n);
    bet.mask := abs(mask);
    bet.gambler := sender;
  } with ((nil: list(operation)), self);

function settleBetCommon (const self : state; const bet : dice2Win_Bet; const reveal : nat; const entropyBlockHash : bytes) : (list(operation) * state) is
  block {
    const res__amount : nat = bet.res__amount;
    const modulo : nat = bet.modulo;
    const rollUnder : nat = bet.rollUnder;
    const gambler : address = bet.gambler;
    assert((res__amount =/= 0n)) (* "Bet should be in an 'active' state" *);
    bet.res__amount := 0n;
    const entropy : bytes = sha_256((reveal, entropyBlockHash));
    const dice : nat = (abs(entropy) mod modulo);
    const diceWinAmount : nat = 0n;
    const jackpotFee_ : nat = 0n;
    (diceWinAmount, jackpotFee_) := getDiceWinAmount(res__amount, modulo, rollUnder);
    const diceWin : nat = 0n;
    const jackpotWin : nat = 0n;
    if (modulo <= self.MAX_MASK_MODULO) then block {
      if (bitwise_and((2n LIGO_IMPLEMENT_ME_PLEASE_POW dice), bet.mask) =/= 0n) then block {
        diceWin := diceWinAmount;
      } else block {
        skip
      };
    } else block {
      if (dice < rollUnder) then block {
        diceWin := diceWinAmount;
      } else block {
        skip
      };
    };
    self.lockedInBets := (self.lockedInBets - abs(diceWinAmount));
    if (res__amount >= self.MIN_JACKPOT_BET) then block {
      const jackpotRng : nat = ((abs(entropy) / modulo) mod self.JACKPOT_MODULO);
      if (jackpotRng = 0n) then block {
        jackpotWin := self.jackpotSize;
        self.jackpotSize := 0n;
      } else block {
        skip
      };
    } else block {
      skip
    };
    if (jackpotWin > 0n) then block {
      (* EmitStatement undefined(gambler, jackpotWin) *)
    } else block {
      skip
    };
    sendFunds(self, gambler, (case ((diceWin + jackpotWin) = 0n) of | True -> 1n | False -> (diceWin + jackpotWin) end), diceWin);
  } with ((nil: list(operation)), self);

function settleBet (const self : state; const reveal : nat; const blockHash : bytes) : (list(operation) * state) is
  block {
    assert((sender = self.croupier)) (* "OnlyCroupier methods called by non-croupier." *);
    const commit : nat = abs(sha_256((reveal)));
    const bet : dice2Win_Bet = (case self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
    const placeBlockNumber : nat = bet.placeBlockNumber;
    assert((0n > placeBlockNumber)) (* "settleBet in the same block as placeBet, or before." *);
    assert((0n <= (placeBlockNumber + self.BET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
    assert((("00" : bytes) (* Should be blockhash of placeBlockNumber *) = blockHash));
    settleBetCommon(self, bet, reveal, blockHash);
  } with ((nil: list(operation)), self);

function memcpy (const dest : nat; const src : nat; const len : nat) : () is
  block {
    while (len >= 32n) block {
      (* InlineAssembly {
          mstore(dest, mload(src))
      } *)
      dest := (dest + 32n);
      src := (src + 32n);
      len := (len - 32n);
    };
    const mask : nat = ((256n LIGO_IMPLEMENT_ME_PLEASE_POW (32n - len)) - 1n);
    (* InlineAssembly {
        let srcpart := and(mload(src), not(mask))
        let destpart := and(mload(dest), mask)
        mstore(dest, or(destpart, srcpart))
    } *)
  } with ();

function verifyMerkleProof (const seedHash : nat; const offset : nat) : ((bytes * bytes)) is
  block {
    const blockHash : bytes = ("00": bytes);
    const uncleHash : bytes = ("00": bytes);
    const scratchBuf1 : nat = 0n;
    (* InlineAssembly {
        scratchBuf1 := mload(0x40)
    } *)
    const uncleHeaderLength : nat = 0n;
    const blobLength : nat = 0n;
    const shift : nat = 0n;
    const hashSlot : nat = 0n;
    while (True) block {
      (* InlineAssembly {
          blobLength := and(calldataload(sub(offset, 30)), 0xffff)
      } *)
      if (blobLength = 0n) then block {
        (* CRITICAL WARNING break is not supported *);
      } else block {
        skip
      };
      (* InlineAssembly {
          shift := and(calldataload(sub(offset, 28)), 0xffff)
      } *)
      assert(((shift + 32n) <= blobLength)) (* "Shift bounds check." *);
      offset := (offset + 4n);
      (* InlineAssembly {
          hashSlot := calldataload(add(offset, shift))
      } *)
      assert((hashSlot = 0n)) (* "Non-empty hash slot." *);
      (* InlineAssembly {
          calldatacopy(scratchBuf1, offset, blobLength)
          mstore(add(scratchBuf1, shift), seedHash)
          seedHash := keccak256(scratchBuf1, blobLength)
          uncleHeaderLength := blobLength
      } *)
      offset := (offset + blobLength);
    };
    uncleHash := (seedHash : bytes);
    const scratchBuf2 : nat = (scratchBuf1 + uncleHeaderLength);
    const unclesLength : nat = 0n;
    (* InlineAssembly {
        unclesLength := and(calldataload(sub(offset, 28)), 0xffff)
    } *)
    const unclesShift : nat = 0n;
    (* InlineAssembly {
        unclesShift := and(calldataload(sub(offset, 26)), 0xffff)
    } *)
    assert(((unclesShift + uncleHeaderLength) <= unclesLength)) (* "Shift bounds check." *);
    offset := (offset + 6n);
    (* InlineAssembly {
        calldatacopy(scratchBuf2, offset, unclesLength)
    } *)
    memcpy((scratchBuf2 + unclesShift), scratchBuf1, uncleHeaderLength);
    (* InlineAssembly {
        seedHash := keccak256(scratchBuf2, unclesLength)
    } *)
    offset := (offset + unclesLength);
    (* InlineAssembly {
        blobLength := and(calldataload(sub(offset, 30)), 0xffff)
        shift := and(calldataload(sub(offset, 28)), 0xffff)
    } *)
    assert(((shift + 32n) <= blobLength)) (* "Shift bounds check." *);
    offset := (offset + 4n);
    (* InlineAssembly {
        hashSlot := calldataload(add(offset, shift))
    } *)
    assert((hashSlot = 0n)) (* "Non-empty hash slot." *);
    (* InlineAssembly {
        calldatacopy(scratchBuf1, offset, blobLength)
        mstore(add(scratchBuf1, shift), seedHash)
        blockHash := keccak256(scratchBuf1, blobLength)
    } *)
  } with ((blockHash, uncleHash));

function requireCorrectReceipt (const self : state; const offset : nat) : () is
  block {
    const leafHeaderByte : nat = 0n;
    (* InlineAssembly {
        leafHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((leafHeaderByte >= 0xf7n)) (* "Receipt leaf longer than 55 bytes." *);
    offset := (offset + (leafHeaderByte - 0xf6n));
    const pathHeaderByte : nat = 0n;
    (* InlineAssembly {
        pathHeaderByte := byte(0, calldataload(offset))
    } *)
    if (pathHeaderByte <= 0x7fn) then block {
      offset := (offset + 1n);
    } else block {
      assert(((pathHeaderByte >= 0x80n) and (pathHeaderByte <= 0xb7n))) (* "Path is an RLP string." *);
      offset := (offset + (pathHeaderByte - 0x7fn));
    };
    const receiptStringHeaderByte : nat = 0n;
    (* InlineAssembly {
        receiptStringHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((receiptStringHeaderByte = 0xb9n)) (* "Receipt string is always at least 256 bytes long, but less than 64k." *);
    offset := (offset + 3n);
    const receiptHeaderByte : nat = 0n;
    (* InlineAssembly {
        receiptHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((receiptHeaderByte = 0xf9n)) (* "Receipt is always at least 256 bytes long, but less than 64k." *);
    offset := (offset + 3n);
    const statusByte : nat = 0n;
    (* InlineAssembly {
        statusByte := byte(0, calldataload(offset))
    } *)
    assert((statusByte = 0x1n)) (* "Status should be success." *);
    offset := (offset + 1n);
    const cumGasHeaderByte : nat = 0n;
    (* InlineAssembly {
        cumGasHeaderByte := byte(0, calldataload(offset))
    } *)
    if (cumGasHeaderByte <= 0x7fn) then block {
      offset := (offset + 1n);
    } else block {
      assert(((cumGasHeaderByte >= 0x80n) and (cumGasHeaderByte <= 0xb7n))) (* "Cumulative gas is an RLP string." *);
      offset := (offset + (cumGasHeaderByte - 0x7fn));
    };
    const bloomHeaderByte : nat = 0n;
    (* InlineAssembly {
        bloomHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((bloomHeaderByte = 0xb9n)) (* "Bloom filter is always 256 bytes long." *);
    offset := (offset + (256 + 3));
    const logsListHeaderByte : nat = 0n;
    (* InlineAssembly {
        logsListHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((logsListHeaderByte = 0xf8n)) (* "Logs list is less than 256 bytes long." *);
    offset := (offset + 2n);
    const logEntryHeaderByte : nat = 0n;
    (* InlineAssembly {
        logEntryHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((logEntryHeaderByte = 0xf8n)) (* "Log entry is less than 256 bytes long." *);
    offset := (offset + 2n);
    const addressHeaderByte : nat = 0n;
    (* InlineAssembly {
        addressHeaderByte := byte(0, calldataload(offset))
    } *)
    assert((addressHeaderByte = 0x94n)) (* "Address is 20 bytes long." *);
    const logAddress : nat = 0n;
    (* InlineAssembly {
        logAddress := and(calldataload(sub(offset, 11)), 0xffffffffffffffffffffffffffffffffffffffff)
    } *)
    assert((logAddress = abs(self_address)));
  } with ();

function settleBetUncleMerkleProof (const self : state; const reveal : nat; const canonicalBlockNumber : nat) : (list(operation) * state) is
  block {
    assert((sender = self.croupier)) (* "OnlyCroupier methods called by non-croupier." *);
    const commit : nat = abs(sha_256((reveal)));
    const bet : dice2Win_Bet = (case self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
    assert((0n <= (canonicalBlockNumber + self.BET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
    requireCorrectReceipt(self, (((4 + 32) + 32) + 4));
    const canonicalHash : bytes = ("00": bytes);
    const uncleHash : bytes = ("00": bytes);
    (canonicalHash, uncleHash) := verifyMerkleProof(commit, ((4 + 32) + 32n));
    assert((("00" : bytes) (* Should be blockhash of canonicalBlockNumber *) = canonicalHash));
    settleBetCommon(self, bet, reveal, uncleHash);
  } with ((nil: list(operation)), self);

function refundBet (const self : state; const commit : nat) : (list(operation) * state) is
  block {
    const bet : dice2Win_Bet = (case self.bets[commit] of | None -> dice2Win_Bet_default | Some(x) -> x end);
    const res__amount : nat = bet.res__amount;
    assert((res__amount =/= 0n)) (* "Bet should be in an 'active' state" *);
    assert((0n > (bet.placeBlockNumber + self.BET_EXPIRATION_BLOCKS))) (* "Blockhash can't be queried by EVM." *);
    bet.res__amount := 0n;
    const diceWinAmount : nat = 0n;
    const jackpotFee : nat = 0n;
    (diceWinAmount, jackpotFee) := getDiceWinAmount(res__amount, bet.modulo, bet.rollUnder);
    self.lockedInBets := (self.lockedInBets - abs(diceWinAmount));
    self.jackpotSize := (self.jackpotSize - abs(jackpotFee));
    sendFunds(self, bet.gambler, res__amount, res__amount);
  } with ((nil: list(operation)), self);

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> constructor(self)
  | ApproveNextOwner(match_action) -> approveNextOwner(self, match_action.nextOwner_)
  | AcceptNextOwner(match_action) -> acceptNextOwner(self)
  | Fallback(match_action) -> fallback(self)
  | SetSecretSigner(match_action) -> setSecretSigner(self, match_action.newSecretSigner)
  | SetCroupier(match_action) -> setCroupier(self, match_action.newCroupier)
  | SetMaxProfit(match_action) -> setMaxProfit(self, match_action.maxProfit_)
  | IncreaseJackpot(match_action) -> increaseJackpot(self, match_action.increaseAmount)
  | WithdrawFunds(match_action) -> 
  | Kill(match_action) -> kill(self)
  | PlaceBet(match_action) -> placeBet(self, match_action.betMask, match_action.modulo, match_action.commitLastBlock, match_action.commit, match_action.r, match_action.s)
  | SettleBet(match_action) -> settleBet(self, match_action.reveal, match_action.blockHash)
  | SettleBetUncleMerkleProof(match_action) -> settleBetUncleMerkleProof(self, match_action.reveal, match_action.canonicalBlockNumber)
  | RefundBet(match_action) -> refundBet(self, match_action.commit)
  end);
