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

part of 'opportunity_bloc.dart';

abstract class OpportunityEvent extends Equatable {
  const OpportunityEvent();
  @override
  List<Object> get props => [];
}

class OpportunityFetch extends OpportunityEvent {
  const OpportunityFetch({this.searchString = '', this.refresh = false});
  final String searchString;
  final bool refresh;
  @override
  List<Object> get props => [searchString, refresh];
}

class OpportunitySearchOn extends OpportunityEvent {}

class OpportunitySearchOff extends OpportunityEvent {}

class OpportunityUpdate extends OpportunityEvent {
  const OpportunityUpdate(this.opportunity);
  final Opportunity opportunity;
}

class OpportunityDelete extends OpportunityEvent {
  const OpportunityDelete(this.opportunity);
  final Opportunity opportunity;
}
