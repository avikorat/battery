
String convertUUID(String data){
  return '0X${data.toUpperCase().substring(4, 8)}';
}