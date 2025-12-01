import 'package:flutter/material.dart';

import 'colors.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;

  const ButtonIcon({Key? key, required this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorPrimary, colorPrimary2],
        ),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonPrimary({Key? key, this.name, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
          border: Border.all(width: 2, color: Colors.black),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonPrimaryNoRounded extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonPrimaryNoRounded({Key? key, this.name, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red[900] ?? Colors.transparent, Colors.red],
          ),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonSecondary extends StatelessWidget {
  final String? name;
  final Function onTap;
  const ButtonSecondary({Key? key, this.name, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2, color: Colors.black),
        ),
        child: Text(
          "$name",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
