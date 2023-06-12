import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Text "mo:base/Text";



actor class StudentWall() {

  type Message = Type.Message;
  type Content = Type.Content;


  //count of id message
  stable var messageIdCount : Nat = 0;

  private func _hashNat(n : Nat) : Hash.Hash = return Text.hash(Nat.toText(n));
	let wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, _hashNat);
  
  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    // Id of this hash map 
		let elPepe : Nat = messageIdCount;

    // Create a new message
		var new : Message = 
    {
			content = c;
			creator = caller;
			vote = 0;
		};

    //incress id 
		messageIdCount += 1;

		

		// Instert Data into wall
		wall.put(elPepe, new);

		return elPepe;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {

    let messageRes : ?Message = wall.get(messageId);

		switch (messageRes) 
    {
			case (null) 
      {
				return #err "Unfound message";
			};
			case (?message) 
      {
				return #ok message;
			};
		};
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    //verify the author of the message 
    var verification : Bool = not Principal.isAnonymous(caller);

		if (not verification) 
    {
			return #err "You must be authenticated for this specific message!";
		};

		let messageInfo : ?Message = wall.get(messageId);

		switch (messageInfo) 
    {
			case (null) 
      {
				return #err "This message does not exist.";
			};
			case (?message) 
      {
				if (message.creator != caller) 
        {
					return #err "You are not the owner of this message!";
				};

				let newMessage : Message = 
        {
					creator = message.creator;
					content = c;
					vote = message.vote;
				};

				wall.put(messageId, newMessage);

				return #ok();
			};
		};
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let messageInfo : ?Message = wall.get(messageId);

		switch (messageInfo) 
    {
			case (null) 
      {
				return #err "This message does not exist.";
			};
			case (?message) 
      {
				if (message.creator != caller) 
        {
					return #err "You can't delete this message, you are not the owner!";
				};

				ignore wall.remove(messageId);

				return #ok();
			};
		};

		return #ok();
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {

    let messageInfo : ?Message = wall.get(messageId);

		switch (messageInfo) 
    {
			case (null) 
      {
				return #err "This message does not exist.";
			};
			case (?message) 
      {
				let newMessage : Message = 
        {
					creator = message.creator;
					content = message.content;
					vote = message.vote + 1;
				};

				wall.put(messageId, newMessage);

				return #ok();
			};
		};

		return #ok();
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let messageInfo : ?Message = wall.get(messageId);

		switch (messageInfo) 
    {
			case (null) 
      {
				return #err "This message does not exist.";
			};
			case (?message) 
      {
				let newMessage : Message = 
        {
					creator = message.creator;
					content = message.content;
					vote = message.vote - 1;
				};

				wall.put(messageId, newMessage);

				return #ok();
			};
		};

		return #ok();
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
  
    let messagesInfo = Buffer.Buffer<Message>(0);

//creation of list to return
		for (msg in wall.vals()) 
    {
			messagesInfo.add(msg);
		};
    return Buffer.toArray<Message>(messagesInfo);
	};


  public func getAllMessagesRanked() : async [Message] {
		let messagesInfo = Buffer.Buffer<Message>(0);

		for (msg in wall.vals()) {
			messagesInfo.add(msg);
		};

		var messagesOrd = Buffer.toVarArray<Message>(messagesInfo);


		var tam = messagesOrd.size();


		if (tam > 0) {
			tam -= 1;
		};

		for (first in Iter.range(0, tam)) {
			var max = first;

			for (second in Iter.range(first, tam)) {
				if (messagesOrd[second].vote > messagesOrd[first].vote) {
					max := second;
				};
			};

			let tempo = messagesOrd[max];
			messagesOrd[max] := messagesOrd[first];
			messagesOrd[first] := tempo;
		};

		return Array.freeze<Message>(messagesOrd);
	};
  
};
