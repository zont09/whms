enum StatusCheckInDefine {
  notCheckIn,
  checkIn,
  breakTime,
  resume,
  checkOut
}

extension StatusCheckInDefineExtension on StatusCheckInDefine {
  int get value {
    switch (this) {
      case StatusCheckInDefine.notCheckIn:
        return 0;
      case StatusCheckInDefine.checkIn:
        return 1;
      case StatusCheckInDefine.breakTime:
        return 2;
      case StatusCheckInDefine.resume:
        return 3;
      case StatusCheckInDefine.checkOut:
        return 4;
    }
  }

  static StatusCheckInDefine getStatusByValue(int value) {
    switch (value) {
      case 0: return StatusCheckInDefine.notCheckIn;
      case 1: return StatusCheckInDefine.checkIn;
      case 2: return StatusCheckInDefine.breakTime;
      case 3: return StatusCheckInDefine.resume;
      case 4: return StatusCheckInDefine.checkOut;
      default: return StatusCheckInDefine.notCheckIn;
    }
  }
}