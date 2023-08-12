#
# Plutonium Native Module Boilerplate Generator
# Written by Shahryar Ahmad
#
import json

function buildHeader(var dict)
{
  var header = "#include \"PltObject.h\"
extern \"C\"
{
  PltObject init();
  //Functions"
  var fn = dict["functions"]
  if(len(fn) != 0)
  {
    foreach(var f: fn)
    {
        header+="\n  PltObject "+f["name"]+"(PltObject*,int32_t);"
    }
  }
  var klasses = dict["classes"]
  if(len(klasses) != 0 )
  {
    foreach(var klass: klasses)
    {
      header += "\n  //"+klass["name"]+" methods"
      foreach(var methods: klass["functions"])
      {
        header += format("\n  PltObject %__"+methods["name"]+"(PltObject*,int32_t);",klass["name"])
      }
    }
  }
  header+="\n}"

  return header
}
function typenameToMacro(var name)
{
    if(name == "int")
      return "PLT_INT"
    else if(name == "int64")
      return "PLT_INT64"
    else if(name == "double")
      return "PLT_FLOAT"
    else if(name == "bool")
      return "PLT_BOOL"
    else if(name == "byte")
      return "PLT_BYTE"
    else if(name == "bytearray")
      return "PLT_BYTEARR"
    else if(name == "list")
      return "PLT_LIST"
    else if(name == "dict")
      return "PLT_DICT"
    else if(name == "str")
      return "PLT_STR"
    else if(name == "nil")
      return "PLT_NIL"
    else if(name == "file")
      return "PLT_FILESTREAM"
    else if(name == "object")
      return "PLT_OBJ"
}
function typenameToVariableType(var name)
{
    if(name == "int")
      return "int32_t"
    else if(name == "int64")
      return "int64_t"
    else if(name == "double")
      return "double"
    else if(name == "bool")
      return "bool"
    else if(name == "byte")
      return "uint8_t"
    else if(name == "bytearray")
      return "vector<uint8_t>&"
    else if(name == "list")
      return "PltList&"
    else if(name == "dict")
      return "Dictionary&"
    else if(name == "str")
      return "const string&"
    else if(name == "nil")
      return "PltObject"
    else if(name == "file")
      return "FileObject&"
    else if(name == "object")
      return "KlassObject&"
}
function convertArg(var name,var i)
{
    if(name == "int")
      return format("args[%].i",i)
    else if(name == "int64")
      return format("args[%].l",i)
    else if(name == "double")
      return format("args[%].f",i)
    else if(name == "bool")
      return format("(bool)args[%].i",i)
    else if(name == "byte")
      return format("(uint8_t)args[%].i",i)
    else if(name == "bytearray")
      return format("*(vector<uint8_t>*)args[%].ptr",i)
    else if(name == "list")
      return format("*(PltList*)args[%].ptr",i)
    else if(name == "dict")
      return format("*(Dictionary*)args[%].ptr",i)
    else if(name == "str")
      return format("*(string*)args[%].ptr",i)
    else if(name == "nil")
      return "nil"
    else if(name == "file")
      return format("*(FileObject*)args[%].l",i)
    else if(name == "object")
      return format("(KlassObject*)args[%].l",i)
}
function buildTypecheck(var type,var i)
{
  var res = format("if(args[%].type != %)
    return Plt_Err(TypeError,\"Argument % must be of type %\");",i,typenameToMacro(type),i+1,type)
  return res
}

function getArg(var type,var name,var i)
{
    var res = format("% % = %;",typenameToVariableType(type),name,convertArg(type,i))
    return res
}
function buildReturnVaraible(var name)
{
    # name is the typename
    if(name == "int")
      return "int32_t ret = 0;"
    else if(name == "int64")
      return "int64_t ret = 0;"
    else if(name == "double")
      return "double ret = 0;"
    else if(name == "bool")
      return "bool ret = false;"
    else if(name == "byte")
      return "uint8_t ret = 0;"
    else if(name == "bytearray")
      return "vector<uint8_t>* ret = vm_allocByteArray();"
    else if(name == "list")
      return "PltList* ret = vm_allocList();"
    else if(name == "dict")
      return "Dictionary* ret = vm_allocDict();"
    else if(name == "str")
      return "string* ret = vm_allocString();"
    else if(name == "nil")
      return ""
    else if(name == "file")
      return "FileObject* ret = vm_allocFileObject()"
    else if(name == "object")
      return "KlassObject* ret = vm_allocKlassObject();"
}
function buildReturnStmt(var name)
{
    # name is the typename
    if(name == "nil")
      return "return nil;"
    else if(name == "int")
      return "return PObjFromInt(ret);"
    else if(name == "int64")
      return "return PObjFromInt64(ret);"
    else if(name == "double")
      return "return PObjFromDouble(ret);"
    else if(name == "bool")
      return "return PObjFromBool(ret);"
    else if(name == "byte")
      return "return PObjFromByte(ret);"
    else if(name == "bytearray")
      return "return PObjFromByteArr(ret);"
    else if(name == "list")
      return "return PObjFromList(ret);"
    else if(name == "dict")
      return "return PObjFromDict(ret);"
    else if(name == "str")
      return "return PObjFromStrPtr(ret);"
    else if(name == "file")
      return "return PObjFromFile(ret);"
    else if(name == "object")
      return "return PObjFromKlassObj(ret);"
}
function buildFunction(var fn)
{
  var res = format("PltObject %(PltObject* args,int32_t n)
{
  if(n!=%)
    return Plt_Err(ArgumentError,\"% arguments required!\");",fn["name"],len(fn["args"]),len(fn["args"]))
  var args = fn["args"]
  var types = fn["types"]
  var variables = ""
  var retType = fn["returns"]
  if(len(args) != 0)
  {
    variables += ("\n  //Parameters")
    var i = 0
    foreach(var arg: args)
    {
        res += "\n  "+buildTypecheck(types[i],i)
        variables += format("\n  %",getArg(types[i],arg,i))
        i+=1

    }
    res+="\n"+variables


  } 
  if(retType!= "nil")
  {
    res+="\n\n  //following variable will be returned, change it's value in your logic\n"
    res+="  "+buildReturnVaraible(retType)
  }
  res += "\n\n  // Your logic\n\n  /////////////"
  res += "\n  "+buildReturnStmt(retType)
  res += "\n}"
  return res 
}
function buildMethod(var fn,var classname) # build member functions
{
  var res = format("PltObject %__%(PltObject* args,int32_t n)
{
  if(n!=%)
    return Plt_Err(ArgumentError,\"% arguments required!\");",classname,fn["name"],len(fn["args"])+1,len(fn["args"])+1)
  var args = fn["args"]
  var types = fn["types"]
  var variables = ""
  var retType = fn["returns"]
  res+=format("\n  if(args[0].type != PLT_OBJ || ((KlassObject*)args[0].ptr)->klass != %Klass)
    return Plt_Err(TypeError,\"self is not an object of % class\");",classname,classname)
  res+="\n  KlassObject& self = *(KlassObject*)args[0].ptr;"
  
  if(len(args) != 0)
  {
    variables += ("\n  //Parameters")
    var i = 0
    foreach(var arg: args)
    {
        res += "\n  "+buildTypecheck(types[i],i+1)
        variables += format("\n  %",getArg(types[i],arg,i+1))
        i+=1

    }
    res+="\n"+variables
    
  } 
  if(retType!= "nil")
  {
    res+="\n\n  //following variable will be returned, change it's value in your logic\n"
    res+="  "+buildReturnVaraible(retType)
  }
  res += "\n\n  // Your logic\n\n  /////////////"
  res += "\n  "+buildReturnStmt(retType)
  res += "\n}"
  return res 
}
function buildCpp(var dict)
{
  var cpp = "#include \""+dict["name"]+".h\"
  
using namespace std;\nPltObject nil;\n"
  var classes = dict["classes"]
  foreach(var klass: classes)
  {
    cpp += format("\nKlass* %Klass;",klass["name"])
  }
  cpp+="

PltObject init()
{
  nil.type = PLT_NIL;
  Module* m = vm_allocModule();"
  var functions = dict["functions"]
  var impl = ""
  if(len(functions) != 0)
  {
    foreach(var fn: functions)
    {
        var N = fn["name"]
        cpp += format("\n  m->members.emplace(\"%\",PObjFromFunction(\"%\",&%));",N,N,N)
        impl += "\n"+buildFunction(fn)
    }
  }


  if(len(classes) != 0)
  {
    cpp += "\n  //Classes"
    foreach(var klass: classes)
    {
        cpp += format("\n  %Klass = vm_allocKlass();",klass["name"])
        foreach(var prop: klass["properties"])
        {
            cpp += format("\n  %Klass->members.emplace(\"%\",nil);",klass["name"],prop)
        }
        var methods = klass["functions"]
        foreach(var method: methods)
        {
            impl += "\n"+buildMethod(method,klass["name"])
            cpp += format("\n  %Klass->members.emplace(\"%\",PObjFromMethod(\"\",&%__%,%Klass));",klass["name"],method["name"],klass["name"],method["name"],klass["name"],method["name"])
        }
        cpp += format("\n  m->members.emplace(\"%\",PObjFromKlass(%Klass));",klass["name"],klass["name"])
    }
  }
  cpp +="\n  return PObjFromModule(m);\n}"
  cpp += "\n"+impl
  return cpp
}
function askAndBuild()
{
    var dict = {}
    var name = input("Enter module name: ")
    var n = int(input("How many functions does the module have? "))
    dict.emplace("name", name)
    dict.emplace("functions",[])
    dict.emplace("classes",[])
    for(var i=1 to n step 1)
    {
        println("--Function ",i,"--")
        var fnName = input("Enter function name: ")
        var args = input("Enter argument names(comma seperated): ")
        args = split(args,",")
        if(args == [""])
          args = []
        var types = input("Enter argument types(comma seperated): ")
        types = split(types,",")
        if(types == [""])
          types = []
        var ret = input("Enter return type: ")
        var fn = {"name": fnName,"args": args,"types": types,"returns": ret}
        dict["functions"].push(fn)
    }
    n = int(input("How many classes does the module have? "))
    for(var i=1 to n step 1)
    {
        println("--Class ",i,"--")
        var classname = input("Enter class name: ")
        var props = input("Enter properties of class(comma seperated): ")
        props = split(props,",")
        if(props == [""])
          props = []
        var k = int(input("How many methods does this class have? "))
        var klass = {"name": classname,"properties": props}
        klass.emplace("functions",[])
        for(var j=1 to k step 1)
        {
            println("--Method ",j,"--")
            var fnName = input("Enter Method name: ")
            var args = input("Enter argument names(comma seperated): ")
            args = split(args,",")
            if(args == [""])
            args = []
            var types = input("Enter argument types(comma seperated): ")
            types = split(types,",")
            if(types == [""])
            types = []
            var ret = input("Enter return type: ")
            var fn = {"name": fnName,"args": args,"types": types,"returns": ret}
            klass["functions"].push(fn)
        }
        dict["classes"].push(klass)
    }
    var str = json.dumps(dict)
    var file = open("draft.json","w")
    write(str,file)
    close(file)

    var header = buildHeader(dict)
    var cpp = buildCpp(dict)

    file = open(dict["name"]+".h","w")
    write(header,file)
    close(file)
    file = open(dict["name"]+".cpp","w")
    write(cpp,file)
    close(file)
}
askAndBuild()
# Uncomment the following to directly build from json
#var content = read(open("module.json","r"))
#var dict = json.loads(content)

#var header = buildHeader(dict)
#var cpp = buildCpp(dict)

#var file = open(dict["name"]+".h","w")
#write(header,file)
#close(file)
#file = open(dict["name"]+".cpp","w")
#write(cpp,file)
#close(file)