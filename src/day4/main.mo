import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Account "Account";
import RemoteCanisterActor "RemoteCanisterActor";


actor class MotoCoin() 
{
  public type Account = Account.Account;

  stable var coinInfo = {
    name : Text = "MotoCoin";
    symbol : Text = "MOC";
    var supply : Nat = 0;
  };

  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  // Returns the name of the token
  public query func name() : async Text {
    return coinInfo.name;
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return coinInfo.symbol;
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    return coinInfo.supply;
  };

  // Returns the balanceOf an account
  public query func balanceOf(account : Account) : async (Nat) {
    let userAccount : ?Nat = ledger.get(account);

    switch (userAccount) {
      case(null) { return 0 };
      case(?pepe) {
        return pepe;
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer( from : Account, to : Account, amount : Nat ) : async Result.Result<(), Text> {
    let xAccount : ?Nat = ledger.get(from);

    switch (xAccount) {
      case(null) { 
        return #err ("Your " # coinInfo.name # " balance is not enough! please $"); 
      };

      case(?xActBalance) {
        if (xActBalance < amount) {
          return #err ("Your " # coinInfo.name # " balance is not enough! please $"); 
        };

        // Update sender account balance
        ignore ledger.replace(from, xActBalance - amount);

        // Update receiver account balance
        let xTargetAccount : ?Nat = ledger.get(to);
        switch (xTargetAccount) {
          case(null) {
            ledger.put(to, amount);
            return #ok ()
          };

          case(?xTranxbal) {
            ignore ledger.replace(to, xTranxbal + amount);
            return #ok ()
          }
        };
      };
    };
  };

  // helper function to add coins to a wallet
  private func addBalance(wallet : Account, amount : Nat) : async () {
    let xAccount : ?Nat = ledger.get(wallet);

    switch (xAccount) {
      case(null) { 
        ledger.put(wallet, amount);
        
        return ();
      };

      case(?xBalance) {
        ignore ledger.replace(wallet, xBalance + amount);

        return ();
      };
    }
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    try {
      var estudents : [Principal] = await RemoteCanisterActor.RemoteActor.getAllStudentsPrincipal();

      for (studentes in estudents.vals()) {
        var studentAcc = {owner = studentes; subaccount = null};
        await addBalance(studentAcc, 100);
        coinInfo.supply += 100;
      };

      return #ok ();
    } catch (e) {
      return #err "error in airdrop!";
    };
  };
};