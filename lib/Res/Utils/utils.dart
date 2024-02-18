import 'package:fluttertoast/fluttertoast.dart';
import 'package:pune_task/Res/Colors/app_colors.dart';

class Utils {
  // todo: Flutter Toast

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.blackColor,
      textColor: AppColors.whiteColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  //!
}
