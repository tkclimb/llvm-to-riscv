; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -O3 -attributor-disable=false -S < %s                    | FileCheck %s --check-prefixes=ANY,OLDPM
; RUN: opt -passes='default<O3>' -attributor-disable=false -S < %s  | FileCheck %s --check-prefixes=ANY,NEWPM

@p = external global [2 x i8*], align 16

define void @test(i8* %arg, i32 %arg1) {
; OLDPM-LABEL: @test(
; OLDPM-NEXT:  bb5:
; OLDPM-NEXT:    [[TMP:%.*]] = tail call i8* @strchr(i8* nofree nonnull dereferenceable(1) [[ARG:%.*]], i32 [[ARG1:%.*]]) #1
; OLDPM-NEXT:    store i8* [[TMP]], i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 0), align 16
; OLDPM-NEXT:    [[TMP4:%.*]] = tail call i8* @foo(i8* nonnull [[ARG]])
; OLDPM-NEXT:    store i8* [[TMP4]], i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 1), align 8
; OLDPM-NEXT:    ret void
;
; NEWPM-LABEL: @test(
; NEWPM-NEXT:  bb:
; NEWPM-NEXT:    [[TMP:%.*]] = tail call i8* @strchr(i8* nonnull dereferenceable(1) [[ARG:%.*]], i32 [[ARG1:%.*]])
; NEWPM-NEXT:    store i8* [[TMP]], i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 0), align 16
; NEWPM-NEXT:    [[TMP2:%.*]] = icmp eq i8* [[ARG]], null
; NEWPM-NEXT:    br i1 [[TMP2]], label [[BB5:%.*]], label [[BB3:%.*]]
; NEWPM:       bb3:
; NEWPM-NEXT:    [[TMP4:%.*]] = tail call i8* @foo(i8* nonnull [[ARG]])
; NEWPM-NEXT:    br label [[BB5]]
; NEWPM:       bb5:
; NEWPM-NEXT:    [[TMP6:%.*]] = phi i8* [ [[TMP4]], [[BB3]] ], [ null, [[BB:%.*]] ]
; NEWPM-NEXT:    store i8* [[TMP6]], i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 1), align 8
; NEWPM-NEXT:    ret void
;
bb:
  %tmp = tail call i8* @strchr(i8* %arg, i32 %arg1)
  store i8* %tmp, i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 0), align 16
  %tmp2 = icmp eq i8* %arg, null
  br i1 %tmp2, label %bb5, label %bb3

bb3:                                              ; preds = %bb
  %tmp4 = tail call i8* @foo(i8* %arg)
  br label %bb5

bb5:                                              ; preds = %bb3, %bb
  %tmp6 = phi i8* [ %tmp4, %bb3 ], [ null, %bb ]
  store i8* %tmp6, i8** getelementptr inbounds ([2 x i8*], [2 x i8*]* @p, i64 0, i64 1), align 8
  ret void
}

declare i8* @strchr(i8*, i32)
declare i8* @foo(i8*)
