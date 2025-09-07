import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/manager/views/user_information_view.dart';
import 'package:whms/features/manager/widgets/button_action.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/loading_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.idUser});

  final String idUser;

  @override
  Widget build(BuildContext context) {
    UserModel userCurrent = ConfigsCubit.fromContext(context).user;
    return Material(
        child: FutureBuilder<UserModel?>(
            future: getUserById(idUser, context),
            builder: (c, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }
              if (s.data == null) {
                return Material(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        AppText.textNotFoundInformation.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(30, context),
                            fontWeight: FontWeight.w600,
                            color: ColorConfig.primary1),
                      ),
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: BlocProvider(
                  create: (context) => ProfileCubit(),
                  child: BlocBuilder<ProfileCubit, int>(
                    builder: (cc, ss) {
                      var cubit = BlocProvider.of<ProfileCubit>(cc);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ScaleUtils.scaleSize(20, context),),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(150, context)),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (GoRouter.of(context).canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.login);
                                }
                              },
                              child: Text(
                                AppText.titleBackToPreviousPage.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(18, context),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          UserInformationView(
                            cubit: null,
                            isEdit: cubit.isEdit,
                            user: s.data!,
                            profileCubit: cubit,
                          ),
                          SizedBox(
                            height: ScaleUtils.scaleSize(35, context),
                          ),
                          if ((userCurrent.roles <= 20 ||
                              userCurrent.id == idUser) &&
                              !cubit.isEdit)
                            ButtonAction(
                              cubit: cubit,
                              user: s.data,
                            ),
                          SizedBox(
                            height: ScaleUtils.scaleSize(60, context),
                          )
                        ],
                      );
                    },
                  ),
                ),
              );
            }));
    // return BlocBuilder<ConfigsCubit, ConfigsState>(
    //   builder: (context, state) {
    //     return Material(
    //         child: FutureBuilder<UserModel?>(
    //             future: getUserById(idUser, context),
    //             builder: (c, s) {
    //               if (s.connectionState == ConnectionState.waiting) {
    //                 return const LoadingWidget();
    //               }
    //               if (s.data == null) {
    //                 return Material(
    //                   child: SizedBox(
    //                     height: MediaQuery.of(context).size.height,
    //                     width: MediaQuery.of(context).size.width,
    //                     child: Center(
    //                       child: Text(
    //                         AppText.textNotFoundInformation.text,
    //                         style: TextStyle(
    //                             fontSize: ScaleUtils.scaleSize(30, context),
    //                             fontWeight: FontWeight.w600,
    //                             color: ColorConfig.primary1),
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               }
    //               return SingleChildScrollView(
    //                 child: BlocProvider(
    //                   create: (context) => ProfileCubit(),
    //                   child: BlocBuilder<ProfileCubit, int>(
    //                     builder: (cc, ss) {
    //                       var cubit = BlocProvider.of<ProfileCubit>(cc);
    //                       return Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           SizedBox(height: ScaleUtils.scaleSize(20, context),),
    //                           Padding(
    //                             padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(150, context)),
    //                             child: InkWell(
    //                               splashColor: Colors.transparent,
    //                               hoverColor: Colors.transparent,
    //                               highlightColor: Colors.transparent,
    //                               onTap: () {
    //                                 if (GoRouter.of(context).canPop()) {
    //                                   context.pop();
    //                                 } else {
    //                                   context.go(AppRoutes.login);
    //                                 }
    //                               },
    //                               child: Text(
    //                                 AppText.titleBackToPreviousPage.text,
    //                                 style: TextStyle(
    //                                     fontSize: ScaleUtils.scaleSize(18, context),
    //                                     color: Colors.black,
    //                                     fontWeight: FontWeight.w700),
    //                               ),
    //                             ),
    //                           ),
    //                           UserInformationView(
    //                             cubit: null,
    //                             isEdit: cubit.isEdit,
    //                             user: s.data!,
    //                             profileCubit: cubit,
    //                           ),
    //                           SizedBox(
    //                             height: ScaleUtils.scaleSize(35, context),
    //                           ),
    //                           if ((userCurrent.roles <= 20 ||
    //                                   userCurrent.id == idUser) &&
    //                               !cubit.isEdit)
    //                             ButtonAction(
    //                               cubit: cubit,
    //                               user: s.data,
    //                             ),
    //                           SizedBox(
    //                             height: ScaleUtils.scaleSize(60, context),
    //                           )
    //                         ],
    //                       );
    //                     },
    //                   ),
    //                 ),
    //               );
    //             }));
    //   },
    // );
  }

  Future<UserModel?> getUserById(String idU, BuildContext context) async {
    UserModel userCurrent = ConfigsCubit.fromContext(context).user;
    if (userCurrent.roles == 0 || userCurrent.roles > 20) {
      if (userCurrent.id != idU) {
        return null;
      }
    }
    final user = await UserServices.instance.getUserById(idU);
    return user;
  }
}

class ProfileCubit extends Cubit<int> {
  ProfileCubit() : super(0);

  bool isEdit = false;

  changeEdit(bool value) {
    isEdit = value;
    emit(state + 1);
  }
}
