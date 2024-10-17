import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

//Đây là header của app
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              
            },
            child: Container (
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                )
                ],
                borderRadius: BorderRadius.circular(15)
              ),
              child: const Icon(
                Icons.sort_rounded,
                size: 28,
              )
            ),
          ), 
          Row(
            children: [
                Icon(Icons.location_on, 
                color: Colors.blueAccent,
                ), 
                Text(
                  "HCM, Việt Nam",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )
            ],
          ), 
          InkWell(
            onTap:() {
              
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6
                  )
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.search,
                size: 28,
              ),
            ),
          )
        ],
      ),

    );
  }
}