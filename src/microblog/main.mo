import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
 
actor {
 
    public type Message =  {
        content : Text; 
        time : Time.Time;
    };

    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared(Text) -> async ();
        posts: shared query (since: Time.Time) -> async [Message];
        timeline : shared () -> async [Message];
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal) : async (){
        followed := List.push(id, followed);
    };

    public shared query func follows() : async [Principal]{
        List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();


    public shared (msg) func post(text: Text) : async () {
        assert(Principal.toText(msg.caller) == "sz2vl-rh25x-2ocfs-ivonm-ja6ma-go6m6-lwzts-ogkcb-55j7o-xrga7-mqe");
        var m ={
            content = text;
            time = Time.now();
        };
        
        messages := List.push<Message>(m,messages);
    };

    public shared query func posts(since: Time.Time) : async [Message] {
        var m : List.List<Message> = List.nil();
        m := List.filter<Message>(messages, func ({ time }) = time >= since);
        List.toArray(m);
    };


    public shared func timeline(since: Time.Time) : async [Message]{
        var all : List.List<Message> = List.nil();

        for (id in Iter.fromList(List.reverse(followed))){
            let canister : Microblog = actor(Principal.toText(id));
            let msgs : [Message] = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)){
                all := List.push(msg, all);
            }
        };
        List.toArray(List.filter<Message>(all, func ({ time }) = time >= since));
    };




};

