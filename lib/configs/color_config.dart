import 'package:flutter/material.dart';

class ColorConfig {
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF000000);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textQuaternary = Color(0xFF646464);
  static const Color textColor5 = Color(0xFF525252);
  static const Color textColor6 = Color(0xFF332233);
  static const Color textColor7 = Color(0xFFA6A6A6);

  static const Color textColor = Color(0xFF323232);
  static const Color hintText = Color(0xFF7B7C7D);
  static Color shadow = const Color(0xFF000000).withOpacity(0.25);
  static const Color mainLogin = Color(0xFF0086f3);
  static const Color error = Color(0xFFE41E26);
  static const Color border = Color(0xFFD9D9D9);
  static const Color border2 = Color(0xFFACACAC);
  static const Color border4 = Color(0xFFD7D7D7);
  static const Color border3 = Color(0xFF630404);
  static const Color border5 = Color(0xFFB71C1C);
  static const Color border6 = Color(0xFFEDEDED);
  static const Color border7 = Color(0xFFE7E7E7);
  static const Color border8 = Color(0xFFE8E8E8);
  static const Color border9 = Color(0xFFEBEBEB);
  static const Color border10 = Color(0xFFBEBEBE);
  static const Color slider = Color(0xFF009368);
  static const Color addressTask = Color(0xFF950606);
  static const Color disable = Color(0xFFACACAC);

  static const Color whiteBackground = Color(0xFFF7F7F7);

  static LinearGradient backgroundLogin() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFC41D1F),
        Color(0xFFFF3B57),
      ],
    );
  }

  static const Color redState = Color(0xFFFF474E);
  static const Color greenState = Color(0xFF65C728);
  static const Color yellowState = Color(0xFFFFC800);

  static const Color redLogo = Color(0xFFC91D20);
  static const Color redTitle = Color(0xFFBF0000);
  static const Color yellowCreatorScope = Color(0xFFFFF1BC);

  static const Color primary1 = Color(0xFF0448db);
  static const Color primary2 = Color(0xFF006df5);
  static const Color primary3 = Color(0xFF0086f3);
  static const Color primary4 = Color(0xFF0099d8);
  static const Color primary5 = Color(0xFFabc5ff);

  // static const Color primary1 = Color(0xFF162D61);
  // static const Color primary2 = Color(0xFF0F3A9D);
  // static const Color primary3 = Color(0xFF265CDE);
  // static const Color primary4 = Color(0xFF4182F9);
  // static const Color primary5 = Color(0xFF749BEE);
  static const Color primary6 = Color(0xFFE7EDFF);
  static const Color primary7 = Color(0xFFE6EFF5);

  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFF0448db),
      Color(0xFF006df5),
      Color(0xFF0086f3),
    ],
    stops: [0.0, 0.2607, 0.5606],
  );
  static const LinearGradient gradientPrimary2 = LinearGradient(
    colors: [
      Color(0xFF530303),
      Color(0xFF630404),
      Color(0xFF980606),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.525, 1.0],
  );

  static const LinearGradient gradientPrimary3 = LinearGradient(
    colors: [
      Color(0xFFE41E26),
      Color(0xFFC41D1F),
      Color(0xFFB71C1C),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.7094, 1.0],
  );

  static const LinearGradient gradientPrimary4 = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.25),
      Color.fromRGBO(255, 255, 255, 0),
    ],
    stops: [0.0, 1.0],
  );

  static const Color mainText = Color(0xFF343C6A);
  static const Shadow textShadow = Shadow(
    offset: Offset(0, 4), // Độ lệch ngang và dọc của bóng
    blurRadius: 4, // Độ mờ của bóng
    color: Color(0x1A000000), // Màu của bóng
  );

  static const BoxShadow boxShadow = BoxShadow(
    color: Color(0x26000000), // Mã màu #00000026
    offset: Offset(0, 2), // Dịch chuyển bóng: x=0, y=2
    blurRadius: 4, // Độ mờ
    spreadRadius: 0, // Độ lan tỏa
  );

  static const BoxShadow boxShadow2 = BoxShadow(
    color: Color(0x26000000), // Mã màu #00000026 (15% độ mờ)
    offset: Offset(1, 1), // Dịch chuyển bóng: x=1, y=1
    blurRadius: 5.9, // Độ mờ của bóng
    spreadRadius: 0, // Độ lan tỏa
  );

  static const Color statusDoneText = Color(0xFF2C7300);
  static const Color statusDoneBG = Color(0xFFDFFEF5);
  static const Color statusFixingText = Color(0xFF4A24FF);
  static const Color statusFixingBG = Color(0xFFEEECFC);
  static const Color statusPendingText = Color(0xFF757575);
  static const Color statusPendingBG = Color(0xFFD9D9D9);
  static const Color statusCancelledText = Color(0xFF757575);
  static const Color statusCancelledBG = Color(0xFFD9D9D9);
  static const Color statusWaitingText = Color(0xFF986300);
  static const Color statusWaitingBG = Color(0xFFFDFFE2);
  static const Color statusReworkingText = Color(0xFF0F3A9D);
  static const Color statusReworkingBG = Color(0xFFE1EAFF);
  static const Color statusFailedText = Color(0xFFFF474E);
  static const Color statusFailedBG = Color(0xFFFFC1C1);
  static const Color statusCompletedText = Color(0xFF004C17);
  static const Color statusCompletedBG = Color(0xFFBAFF90);
  static const Color statusRevisingText = Color(0xFF009368);
  static const Color statusRevisingBG = Color(0xFFCDFFF1);
  static const Color statusProcessingText = Color(0xFF0F3A9D);
  static const Color statusProcessingBG = Color(0xFFE1EAFF);

  static const Color timePrimary = Color(0xFF058227);
  static const Color timeSecondary = Color(0xFFC7FFD8);

  static const Color issueBug = Color(0xFFED6214);
  static const Color issueRecommend = Color(0xFF891D06);
  static const Color issueProblem = Color(0xFF004823);
  static const Color issueImprove = Color(0xFF4e9db5);
  static const Color issueConsidering = Color(0xFF0400FF);
  static const Color issueOther = Color(0xFFFF0059);
  static const Color issueComplaint = Color(0xFFFF474E);
  static const Color issueFeedback = Color(0xFF008c0e);

  static const Color issueNew = Color(0xFFffc219);
  static const Color issueSeen = Color(0xFF0F3A9D);
  static const Color issueProcessing = Color(0xFFFF5100);
  static const Color issueProcessed = Color(0xFF2C7300);
  static const Color issuePending = Color(0xFFA6A6A6);
  static const Color issueNotFix = Color(0xFFA6A6A6);
  static const Color issueRemoved = Colors.red;

  static const Color issueCritical = Color(0xFFBF0000);
  static const Color issueUrgent = Color(0xFFEB1E4B);
  static const Color issueHigh = Color(0xFFF06937);
  static const Color issueMedium = Color(0xFF2D969B);
  static const Color issueLow = Color(0xFF419BD2);
  static const Color issueTrivial = Color(0xFFBEAF5F);

  static const Color enhance = Color(0xFF009368);
  static const Color improve = Color(0xFFBF0000);

  static const Color workingPointCl = Color(0xFFFA747F);
}
