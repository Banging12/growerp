/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object> get props => [];
}

class TaskFetch extends TaskEvent {
  const TaskFetch({this.searchString = '', this.refresh = false});
  final String searchString;
  final bool refresh;
  @override
  List<Object> get props => [searchString, refresh];
}

class TaskSearchOn extends TaskEvent {}

class TaskSearchOff extends TaskEvent {}

class TaskUpdate extends TaskEvent {
  const TaskUpdate(this.task);
  final Task task;
}

class TaskTimeEntryUpdate extends TaskEvent {
  const TaskTimeEntryUpdate(this.timeEntry);
  final TimeEntry timeEntry;
}

class TaskTimeEntryDelete extends TaskEvent {
  const TaskTimeEntryDelete(this.timeEntry);
  final TimeEntry timeEntry;
}
