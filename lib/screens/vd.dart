// adding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '4,7',
//                     style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(width: 8),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: List.generate(5, (index) {
//                           return Icon(Icons.star, color: Colors.blue);
//                         }),
//                       ),
//                       SizedBox(height: 4),
//                       Text('Đánh giá nhận xét'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 children: [
//                   buildRatingRow(5, 0.85),
//                   buildRatingRow(4, 0.10),
//                   buildRatingRow(3, 0.05),
//                   buildRatingRow(2, 0.0),
//                   buildRatingRow(1, 0.0),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Image.asset('assets/images/anh1.png', width: 80, height: 80, fit: BoxFit.cover),
//                   Image.asset('assets/images/anh2.png', width: 80, height: 80, fit: BoxFit.cover),
//                   Image.asset('assets/images/anh3.png', width: 80, height: 80, fit: BoxFit.cover),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Nhận xét (33)',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             buildCommentSection('Khoai Lang Thang', '3 giờ 15 phút trước', 'assets/images/user1.png', 4, 'Ở đây có rất nhiều địa điểm để khám phá du lịch.'),
//             buildCommentSection('Kang Ho', '4 ngày trước', 'assets/images/user2.png', 5, 'I was very happy to be exposed to the culture here.'),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/bando.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),