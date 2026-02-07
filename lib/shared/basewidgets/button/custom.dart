
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/shared/basewidgets/button/bounce.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String? btnTxt;
  final bool customText;
  final Widget? text;
  final double width;
  final double height;
  final double sizeBorderRadius;
  final BorderRadiusGeometry borderRadiusGeometry;
  final Color loadingColor;
  final Color btnColor;
  final Color btnTextColor;
  final Color btnBorderColor;
  final double fontSize;
  final bool isBorder;
  final bool isBorderRadius;
  final bool isLoading;
  final bool isBoxShadow;
  final bool isBackgroundImage;
  final bool isPrefixIcon;

  const CustomButton({
    super.key, 
    required this.onTap, 
    this.btnTxt, 
    this.customText = false,
    this.text,
    this.width = double.infinity,
    this.height = 45.0,
    this.fontSize = 14.0,
    this.sizeBorderRadius = 10.0,
    this.isLoading = false,
    this.borderRadiusGeometry = BorderRadius.zero,
    this.loadingColor = ColorResources.white,
    this.btnColor = ColorResources.primary,
    this.btnTextColor = ColorResources.white,
    this.btnBorderColor = Colors.transparent,
    this.isBorder = false,
    this.isBorderRadius = false,
    this.isBoxShadow = false,
    this.isBackgroundImage = false,
    this.isPrefixIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncing(
      onPress: isLoading ? null : onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: isBackgroundImage
            ? const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/background/bg.png',
                )
              )
            : null,
          boxShadow: isBoxShadow 
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.0,
                blurRadius: 10.0,
                offset: const Offset(5.0, 5.0),
              )
            ]
          : [],
          color: btnColor,
          border: Border.all(
            color: isBorder 
            ? btnBorderColor 
            : Colors.transparent,
          ),
          borderRadius: isBorderRadius 
          ? BorderRadius.circular(sizeBorderRadius)
          : borderRadiusGeometry
        ),
        child: isLoading 
        ? Center(
            child: SpinKitFadingCircle(
              color: loadingColor,
              size: 25.0
            ),
          )
        : Row(
            mainAxisAlignment: isPrefixIcon ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
            customText
              ? text! 
              : Center(
                child: Text(btnTxt!,
                  style: montserratRegular.copyWith(
                    color: btnTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize
                  ) 
                ),
              ),
          ],
        )
      ),
    );
  }
}
