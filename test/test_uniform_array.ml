open! Import
open Uniform_array

let does_raise = Exn.does_raise
let zero_obj = Caml.Obj.repr (0 : int)

(* [create_obj_array] *)
let%test_unit _ =
  let t = create_obj_array ~len:0 in
  assert (length t = 0)
;;

(* [create] *)
let%test_unit _ =
  let str = Caml.Obj.repr "foo" in
  let t = create ~len:2 str in
  assert (phys_equal (get t 0) str);
  assert (phys_equal (get t 1) str)
;;

let%test_unit _ =
  let float = Caml.Obj.repr 3.5 in
  let t = create ~len:2 float in
  assert (Caml.Obj.tag (Caml.Obj.repr t) = 0);
  (* not a double array *)
  assert (phys_equal (get t 0) float);
  assert (phys_equal (get t 1) float);
  set t 1 (Caml.Obj.repr 4.);
  assert (Float.( = ) (Caml.Obj.obj (get t 1)) 4.)
;;

(* [empty] *)
let%test _ = length empty = 0
let%test _ = does_raise (fun () -> get empty 0)
(* [singleton] *)
let%test _ = length (singleton zero_obj) = 1
let%test _ = phys_equal (get (singleton zero_obj) 0) zero_obj
let%test _ = does_raise (fun () -> get (singleton zero_obj) 1)

let%test_unit _ =
  let f = 13. in
  let t = singleton (Caml.Obj.repr f) in
  invariant t;
  assert (Poly.equal (Caml.Obj.repr f) (get t 0))
;;

(* [get], [unsafe_get], [set], [unsafe_set], [unsafe_set_assuming_currently_int] *)
let%test_unit _ =
  let t = create_obj_array ~len:1 in
  assert (length t = 1);
  assert (phys_equal (get t 0) zero_obj);
  assert (phys_equal (unsafe_get t 0) zero_obj);
  let one_obj = Caml.Obj.repr (1 : int) in
  let check_get expect =
    assert (phys_equal (get t 0) expect);
    assert (phys_equal (unsafe_get t 0) expect)
  in
  set t 0 one_obj;
  check_get one_obj;
  unsafe_set t 0 zero_obj;
  check_get zero_obj;
  unsafe_set_assuming_currently_int t 0 one_obj;
  check_get one_obj
;;

(* [unsafe_truncate] *)
let%test _ = does_raise (fun () -> unsafe_truncate empty ~len:0)
let%test _ = does_raise (fun () -> unsafe_truncate empty ~len:1)
let%test _ = does_raise (fun () -> unsafe_truncate empty ~len:(-1))
let%test _ = does_raise (fun () -> unsafe_truncate (create_obj_array ~len:1) ~len:0)
let%test _ = does_raise (fun () -> unsafe_truncate (create_obj_array ~len:1) ~len:2)

let%test_unit _ =
  let t = create_obj_array ~len:1 in
  unsafe_truncate t ~len:1;
  assert (length t = 1)
;;

let%test_unit _ =
  let t = create_obj_array ~len:3 in
  unsafe_truncate t ~len:2;
  assert (length t = 2);
  unsafe_truncate t ~len:1;
  assert (length t = 1)
;;

module Sequence = struct
  type nonrec 'a t = 'a t
  type 'a z = 'a

  let length = length
  let get = get
  let set = set
  let create_bool ~len = create ~len false
end

include Base_for_tests.Test_blit.Test1 (Sequence) (Uniform_array)
