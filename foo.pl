#!/usr/bin/env perl -I.
use Mojolicious::Lite;
use DBI;
use Data::Dumper;



get '/' => sub {
    my $c = shift;
    my $d_b_connect =DBI->connect('dbi:Pg:dbname=chat_history ; host=localhost ; port=5432','chat_user','03bepuh')
    or die "Can not connect to the database " .  DBI->errstr;

    my $id;
    my @his_name;
    my @his_msg;
    my $st1;
    my $st2;
    my $number_shown_message=10;
    my $max_id;
    $max_id = $d_b_connect->prepare ("SELECT max(id) FROM msg_history");         
    $max_id->execute();
    $id=($max_id->fetchrow_array); #40
    my $counter_id=$id; #40/40
    if($id<$number_shown_message){$number_shown_message=$id}
    


    while($counter_id<($id+$number_shown_message)){#40<50
        $st2 = $d_b_connect->prepare ("SELECT chat_user_name FROM msg_history WHERE id=? ");         
        $st2->execute($id);
        push @his_name , $st2->fetchrow_array;
        $st1 = $d_b_connect->prepare ("SELECT msg FROM msg_history WHERE id=? ");   
        $st1->execute($id);
        push @his_msg , $st1->fetchrow_array;
        $id--;
    };
    
    
    $c->stash (his_name=>\@his_name );
    $c->stash (his_msg=>\@his_msg );  
    $c->stash (number_shown_message => $number_shown_message);
    $c->render(template => 'index');
};



post '/foo' => sub {
    my $c = shift;
    my $name_not_filtred= $c->param("namePolzovatel") ;
    my $name_filtred= $c->cleanhtml($name_not_filtred);
    my $msg_not_filtred= $c->param("msg") ;
    my $msg_filtred= $c->cleanhtml($msg_not_filtred);
    my $d_b_connect =DBI->connect('dbi:Pg:dbname=chat_history ; host=localhost ; port=5432','chat_user','03bepuh')
    or die "Can not connect to the database " .  DBI->errstr;
    $d_b_connect->do("INSERT INTO  msg_history (chat_user_name, msg) VALUES (?,?)", {}, ($name_filtred, $msg_filtred))||
    die "Can not insert  " .  DBI->errstr;
    $d_b_connect->disconnect;
    $c->render(template => 'index');

};

helper 'cleanhtml' => sub {
   my $self = shift;
    my  $line = shift;
    my  $returned = $line;
        $returned =~ s/&/&#38;/g ;
        $returned =~ s/%/&#37;/g ;
        $returned =~ s/</&#60;/g ;
        $returned =~ s/>/&#62;/g ;
        $returned =~ s/"/&#34;/g ;
        $returned =~ s/'/&#39;/g ;
        $returned =~ s/\\/&#92;/g ;
        $returned =~ s/\//&#47;/g ;
        $returned =~ s/\./&#46;/g ;

    return $returned;
};

app->start;




__DATA__

@@ index.html.ep
% title 'Chat';

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Чат</title>
    <meta name="description" content="чат без регистрации"/>
    <meta name="keywords" content="чат тестовый"/>
    <link rel="icon" type="image/png" href="/iconchat.png">
    

   
   
    %= stylesheet begin

    *{ 
        
        font-size: 20px
        font-family: 'Franklin Gothic Medium',sans-serif;
    }/* применяется ко всему документу*/
    body{
        background-image: url("https://bipbap.ru/wp-content/uploads/2017/04/leto_derevo_nebo_peyzazh_dom_derevya_domik_priroda_3000x2000.jpg");
        
        background-size: cover;
    }
    header{
        position: absolute;
        top: 0%;
    }
    h1{
        
    }"@g"
    p{  
        position:absolute;
        top:8%;
        left: 12%;
        color: red;
    }
    #history_message {
        position:absolute;
        top:13%;
        left: 0;
        border:2px outset #3c95b8;
        height: 55%;
        width: 35%;
        margin: 10px;/*внешние отступы*/
        padding: 10px;/*внутренние отступы*/
        border-radius: 20px;
    }
    #send_message {
        position:absolute;
        top:10%;
        right: 0;
        border:2px outset #3c95b8;
        height: 25%;
        width: 35%;
        margin: 10px;/*внешние отступы*/
        padding: 10px;/*внутренние отступы*/
        border-radius: 20px;
    }

    % end

  

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"> </script> <!-- путь к библиотеке для подключения скриптов-->

</head>
<body >
    <header>
        <h1>Чат без регистрации</h1>
        <hr />
    </header>
        <p>история сообщений</p>
        <div id="history_message"  name="history" > 
            <% for(my$i=0; $i<$number_shown_message; $i++){%>
            <%= $his_name->[$i] %> : <%= $his_msg->[$i] %> <br />
             <% } %>

 
            
      
        </div>

        <div id="send_message">
         
        <form name="test1"  action="/foo" method="POST">
             <label for="imiy">
                введите ваше имя 
            </label>
            <input type="text" value="Гость" 
                placeholder="Гость" 
                name="namePolzovatel" 
                title="Имя может состоять только из букви пробелов"
                id="imiy" maxlength="30" 
                />
            <textarea 
                rows="10" 
                cols="45"
                name="msg"
                title="Введите ваше сообщение"> 
            </textarea>
            <input type="submit"  value="отправить с перезагрузкой для php"/>
        </form> 
        </div>      
    <footer></footer>
</body>
</html>
