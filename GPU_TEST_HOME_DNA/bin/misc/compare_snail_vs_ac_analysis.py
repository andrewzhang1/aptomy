# -*- coding: utf-8 -*-
'''
Program to compare annotations.snail vs annotations.h5 files.
Goal is to characterize the differences between two result files, and to
provide "pass/fail" result to indicate whether the two file's
oc_calibration_single_pore annotation are substantially
the same (return_value = 0 for pass).
'''
from __future__ import division
from argparse import ArgumentParser
from argparse import RawDescriptionHelpFormatter
import os
import sys

import numpy as np
import pandas
import warnings

from ac_analysis.model.annotations import load_from_h5
from genia_data_handling.snail import snail_file
from compare_utls import (assert_close_enough, plot_xy,
                          config_plotting_backend,
                          cell_annos_to_df,
                          snail_annos_to_df,
                          comp_all,
                          mismatch_summary,
                          single_pore_summary,
                          )


def plot_annos(plt, joint_df, anno_list, plot_path):
    for k in anno_list:
        fig = plot_xy(plt, joint_df['snail_'+k].values, joint_df[k].values,
                      title=k, xname='snail', yname='reference'
                      )
        if plot_path is not '':
            fig.savefig(os.path.join(plot_path, k))


def write_df_to_csv(df, out_path, filename, header=True):
    csv_filename = os.path.join(out_path, filename)
    df.to_csv(csv_filename, sep=',', header=header)
    return csv_filename


def main(argv=None):

    if argv is None:
        argv = sys.argv
    else:
        sys.argv.extend(argv)

    program_name = os.path.basename(sys.argv[0])

    parser = ArgumentParser(description='',
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument("--output", dest="output_path",
                        default='.',
                        help=("Output path for per-run comparison reports/plots (defaults to pwd)")
                        )
    parser.add_argument("--summary-file", dest="summary_file",
                        default='',
                        help=("Path to summary report CSV file. Summary results will be "
                              "appended to this file if this argument is present.")
                        )
    parser.add_argument("--snail", dest="snail_filename",
                        default='./annotations.snail',
                        help=("Snail file path/file name.  Default is "
                              "./annotations.snail")
                        )
    parser.add_argument("--ref", dest="ref_filename",
                        default='./annotations.h5',
                        help=("Reference ac-analysis annotations.h5 file "
                              "path/file name.  Default is ./annotations.h5")
                        )
    parser.add_argument("--rtol", dest="rtol",
                        type=float, default=0.02,
                        help=("relative tolerance for difference between "
                              "values that will be ignored (value between "
                              "0.0 to 1.0)")
                        )
    parser.add_argument("--atol", dest="atol",
                        type=float, default=0.15,
                        help=("If the following equation is element-wise True,"
                              " then {0} returns True.\n abs(snail - ref)"
                              " <= (atol + abs(rtol * ref))".
                              format(program_name))
                        )
    parser.add_argument("--sptol", dest="sptol",
                        type=float, default=0.01,
                        help=("single_pore_trivial tolerance.  single_pore_pass "
                              "= True if trivial differences < sptol."
                              )
                        )
    parser.add_argument('--show_plots', action='store_true',
                        dest="show_plots", default=False,
                        help=('Show the comparison plots.')
                        )
    parser.add_argument('--include-ndims', action='store_true',
                        dest="include_ndims", default=False,
                        help=('Include compare of ndim annotations which can take a long time.')
                        )
    parser.add_argument('--write-plots', action='store_true',
                        dest="write_plots", default=False,
                        help=('Write comparison plots to disk.')
                        )

    args = parser.parse_args()

    # List of the numeric cell annotations to get from the annotations files.
    cell_annos = [u'oc_calibration_vmzero',
                  u'oc_calibration_neg_cycle_decay_range',
                  u'oc_calibration_neg_oc',
                  u'oc_calibration_pos_cycle_decay_range',
                  u'oc_calibration_pos_oc',
                  u'oc_calibration_rail_fraction',
                  ]
    # List of the boolean cell annos.  bool_annos get an aggregate compare,
    # with an allowed tolerance for some total number of mismatches.
    bool_annos = [u'oc_calibration_single_pore',
                  ]
    # List of numeric ndim annotations to get from the annotations files.
    # For ndims, each cell has an array, so these need special handling to put
    # into the DataFrame.  These are only used if --include-ndim is passed at
    # the command line.
    if not args.include_ndims:
        # Skip ndim annos unless asked to include them at the command line.
        ndim_annos = []
    else:
        ndim_annos = [u'oc_calibration_pos_cycle_shape',
                      u'oc_calibration_neg_cycle_shape',
                      ]
    # List of all numeric annos.  numeric_annos are compared and will fail if
    # even one value is out of tolerance.
    numeric_annos = cell_annos + ndim_annos
    # List of all cell (not ndim)  annotations to get from the annotations files.
    all_cell_annos = cell_annos + bool_annos

    config_plotting_backend(show_plots=args.show_plots)
    import matplotlib.pyplot as plt  # Need to import after config, not before.

    # suppress pandas warning...
    pandas.options.mode.chained_assignment = None  # default='warn'
    warnings.simplefilter(action="ignore", category=UserWarning)

    # Load the data from annotations files, and save in DataFrames
    snail_annos = snail_file.load_snail_annotations(args.snail_filename)
    try:
        ref_annos = load_from_h5(args.ref_filename)  # read h5 file
    except KeyError as e:
        print("\nH5 error:"
              " {}\n\n".format(e.args[0]))
        raise

    params = ref_annos.get_parameters()
    try:
        ref_df = cell_annos_to_df(ref_annos, all_cell_annos, ndim_annos)
    except KeyError as e:
        print("\nError: Annotation is missing from annotation.h5 file:"
              " {}\n\n".format(e.args[0]))
        raise

    try:
        snail_df = snail_annos_to_df(snail_annos, all_cell_annos, ndim_annos)
    except KeyError as e:
        print("\nError: Annotation is missing from annotation.snail file:"
              " {}\n\n".format(e.args[0]))
        raise

    # Default value if not given in Snail
    mv_to_adc_conv_factor = 2.69
    try:
        mv_to_adc_conv_factor = float(snail_annos['parameter_map']['mv_to_adc_conv_factor'])
    except KeyError as e:
        print("\nWarning: Couldn't find mv_to_adc_conv_factor. Using default.")

    # First filter cells that don't appear in both lists.
    # As of 8/1/16 Snail calculates the active cell list directly from the
    # raw trace. It considers a cell inactive when the raw value is 0 for 2
    # complete bright cycles. ACAP reads in the oc_cal.cel file. There can be a
    # few cells that appear in Snail that are not in ACAP, due to this difference,
    # which is considered OK. Large numbers of cells means that ACAP failed to
    # process one or more banks. The opposite case, when cells are not in Snail
    # but are in ACAP, are considered errors.
    snail_in_acap = snail_df.index.isin(ref_df.index)
    acap_in_snail = ref_df.index.isin(snail_df.index)

    num_snail_extra = np.count_nonzero(~snail_in_acap)
    num_snail_missing = np.count_nonzero(~acap_in_snail)
    if (num_snail_extra or num_snail_missing):
        # Trim out to just include common cells
        snail_df = snail_df[snail_in_acap]
        ref_df = ref_df[acap_in_snail]

    d = { 'cell_count' : ref_df.shape[0],
          'cell_single_pore_count' : ref_df['oc_calibration_single_pore'].sum(),
          'snail_extra_cells' : num_snail_extra,
          'snail_missing_cells' : num_snail_missing
    }
    missing_summary = pandas.DataFrame(data=d, index=[params.id])

    out_of_tol_df, r_diff_df, diff_df = comp_all(snail_df, ref_df,
                                                 run_id=params.id,
                                                 rtol=args.rtol,
                                                 atol=args.atol)
    mm_summary, pass_fail = mismatch_summary(out_of_tol_df, numeric_annos,
                                             run_id=params.id)
    sp_summary = single_pore_summary(out_of_tol_df, ref_df,
                                     run_id=params.id,
                                     mv_to_adc_conv_factor=mv_to_adc_conv_factor,
                                     atol=args.atol,
                                     triv_tol=args.sptol)
    joint_summary = pandas.concat([missing_summary, mm_summary, sp_summary], axis='columns')
    joint_summary['Overall_pass'] = (num_snail_missing == 0 and pass_fail and
                                     sp_summary['single_pore_pass'].values[0])

    if args.summary_file != '':
        if os.path.isfile(args.summary_file):
            write_header = False
        else:
            write_header = True

        csv_summary = joint_summary.to_csv(index=True, header=write_header)
        with open(args.summary_file, "a") as file:
            file.write(csv_summary)

    csv_filename = write_df_to_csv(r_diff_df.select_dtypes(exclude=['object']),
        out_path=args.output_path,
        filename='diff_ref-snail.csv',
        header=True
        )

    if out_of_tol_df.shape[0] > 0:
        # if any differences, write them to a csv file...
        csv_filename = write_df_to_csv(out_of_tol_df,
            out_path=args.output_path,
            filename='out_of_tolerance.csv',
            header=True
            )

    # make the comparison plots
    # ...need to make a joint table so that rows are aligned on the cell_id
    joint_df = pandas.concat([ref_df,
                              snail_df.rename(columns=lambda x: 'snail_' + x)
                              ],
                             axis='columns'
                             )

    if args.write_plots:
        plot_path = args.output_path
    else:
        plot_path = ''

    plot_annos(plt, joint_df, cell_annos, plot_path)
    # show the plots if requested...
    if args.show_plots:
        plt.show()

    # check and adjust the return value...non-zero if any anno out of tolerance
    if joint_summary['Overall_pass'].values[0]:
        retval = 0
    else:
        retval = 1

    return retval


if __name__ == "__main__":
    sys.exit(main())
