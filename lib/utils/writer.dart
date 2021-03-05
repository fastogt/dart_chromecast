List<int> writeUInt32BE(int value) {
  List<int> _list = [0, 0, 0, 0];
  _list[0] = (value & 0xffffffff) >> 24;
  _list[1] = (value & 0xffffffff) >> 16;
  _list[2] = (value & 0xffffffff) >> 8;
  _list[3] = (value & 0xffffffff) & 0xff;
  return _list;
}
