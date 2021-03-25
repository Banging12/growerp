import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/blocs/@blocs.dart';
import 'package:core/forms/@forms.dart';
import 'package:core/widgets/@widgets.dart';
import 'package:core/helper_functions.dart';
import 'package:models/@models.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class UsersForm extends StatefulWidget {
  final String? userGroupId;
  final int? menuIndex;
  final Key? key;
  const UsersForm({this.key, this.userGroupId, this.menuIndex});
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<UsersForm> {
  ScrollController _scrollController = ScrollController();
  double _scrollThreshold = 200.0;
  late UserBloc _userBloc;
  var blocName;
  Authenticate? authenticate;
  List<User>? users;
  bool? hasReachedMax;
  late int limit;
  bool showSearchField = false;
  String? searchString;
  bool isLoading = false;
  late bool isDeskTop;
  late bool isPhone;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    switch (widget.userGroupId) {
      case "GROWERP_M_ADMIN":
        _userBloc = BlocProvider.of<AdminBloc>(context) as UserBloc
          ..add(FetchUser());
        break;
      case "GROWERP_M_EMPLOYEE":
        _userBloc = BlocProvider.of<EmployeeBloc>(context) as UserBloc
          ..add(FetchUser());
        break;
      case "GROWERP_M_SUPPLIER":
        _userBloc = BlocProvider.of<SupplierBloc>(context) as UserBloc
          ..add(FetchUser());
        break;
      case "GROWERP_M_CUSTOMER":
        _userBloc = BlocProvider.of<CustomerBloc>(context) as UserBloc
          ..add(FetchUser());
        break;
      case "GROWERP_M_LEAD":
        _userBloc = BlocProvider.of<LeadBloc>(context) as UserBloc
          ..add(FetchUser());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    limit = (MediaQuery.of(context).size.height / 45).round();
    isPhone = ResponsiveWrapper.of(context).isSmallerThan(TABLET);
    isDeskTop = ResponsiveWrapper.of(context).isLargerThan(TABLET);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthAuthenticated) authenticate = state.authenticate;

      Widget showForm() {
        if (users == null) return LoadingIndicator();
        return ListView.builder(
          itemCount: hasReachedMax! && users!.isNotEmpty
              ? users!.length + 1
              : users!.length + 2,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0)
              return Column(children: [
                ListTile(
                    onTap: (() {
                      setState(() {
                        showSearchField = !showSearchField;
                      });
                    }),
                    leading:
                        Image.asset('assets/images/search.png', height: 30),
                    subtitle: isPhone && !showSearchField
                        ? Text("emailAddress")
                        : null,
                    title: showSearchField
                        ? Row(children: <Widget>[
                            SizedBox(
                                width: ResponsiveWrapper.of(context)
                                        .isSmallerThan(TABLET)
                                    ? MediaQuery.of(context).size.width - 250
                                    : MediaQuery.of(context).size.width - 350,
                                child: TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    hintText:
                                        "search in ID, first and lastname...",
                                  ),
                                  onChanged: ((value) {
                                    searchString = value;
                                  }),
                                  onSubmitted: ((value) {
                                    _userBloc.add(FetchUser(
                                        searchString: value, limit: limit));
                                    setState(() {
                                      showSearchField = false;
                                    });
                                  }),
                                )),
                            ElevatedButton(
                                child: Text('Search'),
                                onPressed: () {
                                  _userBloc.add(FetchUser(
                                      searchString: searchString,
                                      limit: limit));
                                  setState(() {
                                    showSearchField = false;
                                  });
                                })
                          ])
                        : Row(
                            children: <Widget>[
                              Expanded(child: Text("Name")),
                              if (isDeskTop)
                                Expanded(child: Text("login name")),
                              if (!isPhone) Expanded(child: Text("Email")),
                              if (isDeskTop) Expanded(child: Text("Language")),
                              if (isDeskTop &&
                                  widget.userGroupId != "GROWERP_M_EMPLOYEE" &&
                                  widget.userGroupId != "GROWERP_M_ADMIN")
                                Expanded(
                                    child: Text("Company",
                                        textAlign: TextAlign.center)),
                              if (isPhone &&
                                  widget.userGroupId != "GROWERP_M_EMPLOYEE" &&
                                  widget.userGroupId != "GROWERP_M_ADMIN")
                                Expanded(child: Text("Company"))
                            ],
                          ),
                    trailing: Text(' ')),
                Divider(color: Colors.black),
              ]);
            if (index == 1 && users!.isEmpty)
              return Center(
                  heightFactor: 20,
                  child:
                      Text("no records found!", textAlign: TextAlign.center));
            index -= 1;
            return index >= users!.length
                ? BottomLoader()
                : Dismissible(
                    key: Key(users![index].partyId!),
                    direction: DismissDirection.startToEnd,
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: users![index].image != null
                              ? Image.memory(users![index].image!)
                              : Text(users![index].firstName![0]),
                        ),
                        subtitle:
                            isPhone ? Text("${users![index].email}") : null,
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text("${users![index].firstName}, "
                                    "${users![index].lastName}"
                                    "[${users![index].partyId}]")),
                            if (isDeskTop)
                              Expanded(child: Text("${users![index].name}")),
                            if (!isPhone)
                              Expanded(child: Text("${users![index].email}")),
                            if (isDeskTop)
                              Expanded(
                                  child: Text("${users![index].language}")),
                            if (isDeskTop &&
                                widget.userGroupId != "GROWERP_M_EMPLOYEE" &&
                                widget.userGroupId != "GROWERP_M_ADMIN")
                              Expanded(
                                  child: Text("${users![index].companyName}",
                                      textAlign: TextAlign.center)),
                            if (isPhone &&
                                widget.userGroupId != "GROWERP_M_EMPLOYEE" &&
                                widget.userGroupId != "GROWERP_M_ADMIN")
                              Expanded(
                                  child: Text("${users![index].companyName}",
                                      textAlign: TextAlign.center))
                          ],
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(context, '/user',
                              arguments: FormArguments(
                                  object: users![index],
                                  menuIndex: widget.menuIndex));
                          //                        BlocProvider.of<LeadBloc>(context).add(FetchUser());
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete_forever),
                          onPressed: () {
                            _userBloc.add(DeleteUser(users![index]));
                          },
                        )));
          },
        );
      }

      switch (widget.userGroupId) {
        case "GROWERP_M_LEAD":
          return BlocConsumer<LeadBloc, UserState>(listener: (context, state) {
            if (state is UserProblem)
              HelperFunctions.showMessage(
                  context, '${state.errorMessage}', Colors.red);
            if (state is UserSuccess) {
              HelperFunctions.showMessage(context, '${state.message}',
                  state.error ? Colors.red : Colors.green);
            }
          }, builder: (context, state) {
            if (state is UserProblem)
              return FatalErrorForm("Could not load leads!");
            if (state is UserLoading) LoadingIndicator();
            if (state is UserSuccess) {
              isLoading = false;
              users = state.users;
              hasReachedMax = state.hasReachedMax;
            }
            return showForm();
          });
        case "GROWERP_M_CUSTOMER":
          return BlocConsumer<CustomerBloc, UserState>(
              listener: (context, state) {
            if (state is UserProblem)
              HelperFunctions.showMessage(
                  context, '${state.errorMessage}', Colors.red);
            if (state is UserSuccess) {
              HelperFunctions.showMessage(context, '${state.message}',
                  state.error ? Colors.red : Colors.green);
            }
          }, builder: (context, state) {
            if (state is UserProblem)
              return FatalErrorForm("Could not load customers!");
            if (state is UserLoading) isLoading = true;
            if (state is UserSuccess) {
              isLoading = false;
              users = state.users;
              hasReachedMax = state.hasReachedMax;
            }
            return Stack(
                children: [showForm(), if (isLoading) LoadingIndicator()]);
          });
        case "GROWERP_M_ADMIN":
          return BlocConsumer<AdminBloc, UserState>(listener: (context, state) {
            if (state is UserProblem)
              HelperFunctions.showMessage(
                  context, '${state.errorMessage}', Colors.red);
            if (state is UserSuccess) {
              HelperFunctions.showMessage(context, '${state.message}',
                  state.error ? Colors.red : Colors.green);
            }
          }, builder: (context, state) {
            if (state is UserProblem)
              return FatalErrorForm("Could not load administrators!");
            if (state is UserLoading) isLoading = true;
            if (state is UserSuccess) {
              isLoading = false;
              users = state.users;
              hasReachedMax = state.hasReachedMax;
            }
            return Stack(
                children: [showForm(), if (isLoading) LoadingIndicator()]);
          });
        case "GROWERP_M_EMPLOYEE":
          return BlocConsumer<EmployeeBloc, UserState>(
              listener: (context, state) {
            if (state is UserProblem)
              HelperFunctions.showMessage(
                  context, '${state.errorMessage}', Colors.red);
            if (state is UserSuccess) {
              HelperFunctions.showMessage(context, '${state.message}',
                  state.error ? Colors.red : Colors.green);
            }
          }, builder: (context, state) {
            if (state is UserProblem)
              return FatalErrorForm("Could not load employees!");
            if (state is UserLoading) isLoading = true;
            if (state is UserSuccess) {
              isLoading = false;
              users = state.users;
              hasReachedMax = state.hasReachedMax;
            }
            return Stack(
                children: [showForm(), if (isLoading) LoadingIndicator()]);
          });
        case "GROWERP_M_SUPPLIER":
          return BlocConsumer<SupplierBloc, UserState>(
              listener: (context, state) {
            if (state is UserProblem)
              HelperFunctions.showMessage(
                  context, '${state.errorMessage}', Colors.red);
            if (state is UserSuccess) {
              HelperFunctions.showMessage(context, '${state.message}',
                  state.error ? Colors.red : Colors.green);
            }
          }, builder: (context, state) {
            if (state is UserProblem)
              return FatalErrorForm("Could not load suppliers!");
            if (state is UserLoading) isLoading = true;
            if (state is UserSuccess) {
              isLoading = false;
              users = state.users;
              hasReachedMax = state.hasReachedMax;
            }
            return Stack(
                children: [showForm(), if (isLoading) LoadingIndicator()]);
          });
        default:
          return Center(
              child: Text(
                  "should NOT show this for userGroup: ${widget.userGroupId}"));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _userBloc.add(FetchUser(limit: limit, searchString: searchString));
    }
  }
}
