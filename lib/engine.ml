module Engine = struct
  type engine = { e : env;  t : terms; }
  and env = { p : env option; vars: var list }
  and scope  = { prev : scope option; vars:  }
  and terms


  let eval terms = assert false
end
