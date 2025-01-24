open Parse

let std_print values =
  List.iter (fun v -> print_endline (Tree_interp.show_ivalue v)) values;
  Tree_interp.IUnit
;;

let%expect_test "Test tree_interp addition" =
  let test_str =
    parse_str
      {|
      match 10 + 30
      | 20 -> print(true) 
      | 40 -> print(40)
      |}
  in
  let intepreter = Tree_interp.init_interpreter () in
  Tree_interp.add_stdf intepreter { name = "print"; call = std_print };
  Tree_interp.eval intepreter test_str
;;
