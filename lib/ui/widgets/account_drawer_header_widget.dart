import 'package:cached_network_image/cached_network_image.dart';
import 'package:climbing/enums/sign_in_provider_enum.dart';
import 'package:climbing/models/user.dart';
import 'package:climbing/generated/l10n.dart';
import 'package:climbing/ui/dialogs/sign_in_dialog.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'edit_profile_widget.dart';

const double _kAccountDetailsHeight = 49.0;

class AccountDrawerHeader extends StatefulWidget {
  final Function(SignInProvider) signIn;
  final Set<SignInProvider> signInProviderSet;
  final Function onSignOutTap;
  final void Function() updateUserCallback;
  final User user;

  AccountDrawerHeader({
    Key key,
    @required this.onSignOutTap,
    @required this.user,
    @required this.signIn,
    @required this.signInProviderSet,
    @required this.updateUserCallback,
  }) : super(key: key);

  @override
  _AccountDrawerHeaderState createState() => _AccountDrawerHeaderState();
}

class _AccountDrawerHeaderState extends State<AccountDrawerHeader> {
  bool _canVibrate = false;

  editAccount() {
    if (_canVibrate) Vibrate.feedback(FeedbackType.selection);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => EditAccount(
            user: this.widget.user,
            updateUserCallback: this.widget.updateUserCallback,
          ),
          fullscreenDialog: true,
        ));
  }

  signOut() {
    this.widget.onSignOutTap();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> topRowItems = [];
    List<Widget> rows = [];
    if (this.widget.user == null) {
      // Sign In button
      topRowItems.add(PositionedDirectional(
        end: 10.0,
        top: 0.0,
        child: OutlineButton.icon(
            label: Text(S.of(context).signInSignUp,
                style: TextStyle(
                    color: Theme.of(context).primaryIconTheme?.color)),
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).primaryIconTheme?.color),
            onPressed: () {
              if (_canVibrate) Vibrate.feedback(FeedbackType.light);
              showDialog(
                context: context,
                builder: (BuildContext passedContext) => SignInDialog(
                  signIn: (SignInProvider signInProvider) {
                    this.widget.signIn(signInProvider);
                  },
                  signInProviderSet: this.widget.signInProviderSet,
                ),
              );
            }),
      ));
    } else {
      // Avatar
      topRowItems.add(Positioned(
        top: 0.0,
        left: 0.0,
        child: Semantics(
          onTap: editAccount,
          explicitChildNodes: true,
          child: SizedBox(
            width: 77.0,
            height: 77.0,
            child: InkWell(
              onTap: editAccount,
              child: CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage: CachedNetworkImageProvider(
                    this.widget.user.getPictureUrl()),
              ),
            ),
          ),
        ),
      ));

      // Sign Out button
      topRowItems.add(PositionedDirectional(
        end: 10.0,
        top: 0.0,
        child: OutlineButton(
            onPressed: () {
              if (_canVibrate) Vibrate.feedback(FeedbackType.light);
              showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(S.of(context).signOutQuestion),
                    actions: <Widget>[
                      RaisedButton(
                        child: Text(S.of(context).YES),
                        onPressed: () {
                          this.widget.onSignOutTap();
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(S.of(context).NO),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: DefaultTextStyle(
              style: Theme.of(context).primaryTextTheme.bodyText1,
              child: Text(S.of(context).signOut),
            )),
      ));

      // Account name, username and edit account button
      rows.add(
        SizedBox(
          height: _kAccountDetailsHeight,
          child: Row(
            children: <Widget>[
              // Account name/username
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: editAccount,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: DefaultTextStyle(
                                softWrap: false,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText1,
                                overflow: TextOverflow.fade,
                                child: Text(this.widget.user.name.isEmpty
                                    ? ''
                                    : this.widget.user.name),
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: DefaultTextStyle(
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText1,
                              child: Text(this.widget.user.nickname.isEmpty
                                  ? ''
                                  : this.widget.user.nickname),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
              // Edit account button
              Container(
                child: Tooltip(
                  message: S.of(context).editProfile,
                  child: SizedBox(
                    width: 50,
                    child: OutlineButton(
                        shape: CircleBorder(),
                        onPressed: editAccount,
                        child: Icon(
                          Icons.mode_edit,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyText1
                              .color,
                          size: 20,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Top row with avatar and Sign In/Out buttons
    rows.insert(
        0,
        Expanded(
          child: Stack(children: topRowItems),
        ));

    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsetsDirectional.only(
          top: 15.0, start: 15.0, bottom: 9.0, end: 0.0),
      child: SafeArea(
        bottom: false,
        child: Container(
          child: Column(
            children: rows,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Vibrate.canVibrate.then((value) => _canVibrate = value);
  }
}