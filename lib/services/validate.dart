String? validatePass(String? value){
  Pattern pattern = r'\d{8}$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    return 'only 8 char. digit XXXXXXXX required';
  }

  return null;
}


String? validateEmail(String? value){
  Pattern pattern =  r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$';
  RegExp regExp = RegExp(pattern.toString());

  if (!regExp.hasMatch(value.toString())) {
    return 'enter valid email';
  }

  return null;
}