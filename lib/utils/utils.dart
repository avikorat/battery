
String convertUUID(String data){
  return '0x${data.toUpperCase().substring(4, 8)}';
}