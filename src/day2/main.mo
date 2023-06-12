import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;
  
  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    let index = homeworkDiary.size();
    homeworkDiary.add(homework);
    return index;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    switch(homeworkDiary.getOpt(id)){
  case(null)
  {
    return #err("homework with id :" # Nat.toText(id) # "has not been found")
    };
    case(? homework)
    {
      return #ok(homework);
    };
  
    };
    
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    switch(homeworkDiary.getOpt(id))
    {
      case(null)
    {
    return #err("homework with id :" # Nat.toText(id) # "has not been found")
    };
    case(_)
    {
      homeworkDiary.put(id,homework);
      return #ok();
    };
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> 
  {
    switch(homeworkDiary.getOpt(id))
    {
      case(null){
    return #err("homework with id :" # Nat.toText(id) # "has not been found")
    };
    case(? homework)
    {
    let newHomework = {
    title = homework.title;
    description = homework.description;
    dueDate = homework.dueDate;
    completed = true;
    };
    homeworkDiary.put(id,newHomework);
    return #ok();
    };
    };
  
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    switch(homeworkDiary.getOpt(id))
    {
      case(null)
    {
    return #err("homework with id :" # Nat.toText(id) # "has not been found")
    };
    case(_)
    {
      ignore homeworkDiary.remove(id);
      return #ok();
    };
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let homeworkNot = Buffer.Buffer<Homework>(0);
    var count : Nat = 0;

    while(count < homeworkDiary.size()){
      count += 1;
      if(homeworkDiary.get(count).completed != true)
      {
        homeworkNot.add(homeworkDiary.get(count));
      };
    };
    return Buffer.toArray(homeworkNot);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
     var search = Buffer.clone(homeworkDiary);
        
        search.filterEntries(func(_, hw) = Text.contains(hw.title, #text searchTerm) or Text.contains(hw.description, #text searchTerm));

        return Buffer.toArray<Homework>(search);
  };
};
