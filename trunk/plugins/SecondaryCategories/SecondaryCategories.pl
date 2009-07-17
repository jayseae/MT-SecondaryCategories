# ===========================================================================
# A Movable Type plugin to loop over all additional categories on an entry.
# Copyright 2006 Everitz Consulting <everitz.com>.
#
# This program is free software:  You may redistribute it and/or modify it
# it under the terms of the Artistic License version 2 as published by the
# Open Source Initiative.
#
# This program is distributed in the hope that it will be useful but does
# NOT INCLUDE ANY WARRANTY; Without even the implied warranty of FITNESS
# FOR A PARTICULAR PURPOSE.
#
# You should have received a copy of the Artistic License with this program.
# If not, see <http://www.opensource.org/licenses/artistic-license-2.0.php>.
# ===========================================================================
package MT::Plugin::SecondaryCategories;

use base qw(MT::Plugin);
use strict;

use MT;

my $SecondaryCategories;
my $about = {
  name => 'MT-SecondaryCategories',
  description => 'Loop over all additional categories on an entry.',
  author_name => 'Everitz Consulting',
  author_link => 'http://everitz.com/',
  version => '0.0.2'
};
$SecondaryCategories = MT::Plugin::SecondaryCategories->new($about);
MT->add_plugin($SecondaryCategories);

use MT::Template::Context;
MT::Template::Context->add_container_tag(SecondaryCategories => \&SecondaryCategories);
MT::Template::Context->add_tag(SecondaryCategoryCount => \&SecondaryCategoryCount);

sub SecondaryCategories {
  my($ctx, $args, $cond) = @_;

  my $e = $ctx->stash('entry')
    or return $ctx->_no_entry_error('MTEntryCategories');

  my $cats = $e->categories;
  return '' unless $cats && @$cats;

  my $pri = $e->category;

  my $builder = $ctx->stash('builder');
  my $tokens = $ctx->stash('tokens');
  my @res;

  for my $cat (@$cats) {
    local $ctx->{__stash}->{category} = $cat;
    defined(my $out = $builder->build($ctx, $tokens, $cond))
      or return $ctx->error( $builder->errstr );
    push @res, $out unless ($cat eq $pri);
  }

  my $sep = $args->{glue} || '';
  join $sep, @res;;
}

sub SecondaryCategoryCount {
  my($ctx, $args, $cond) = @_;

  my $e = $ctx->stash('entry')
    or return $ctx->_no_entry_error('MTEntryCategories');

  my $cats = $e->categories;
  if ($cats) {
    return scalar @$cats - 1;
  } else {
    return '';
  }
}

1;

