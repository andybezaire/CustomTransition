//
//  PushInsetSegue.swift
//  CustomTransition
//
//  Created by Andy Bezaire on 2015-04-15.
//  Copyright (c) 2015 dnnjn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class PushInsetSegue: UIStoryboardSegue {
  
  struct Const {
    static let InsetWidthPct:  CGFloat = 70.0
    static let InsetHeightPct: CGFloat = 30.0
  }
  
  lazy var transitioningDelegate: PushInsetTransitioningDelegate? = {
    let pushInsetTD = PushInsetTransitioningDelegate()
    pushInsetTD.callingSegue = self // keep me alive until dismissal
    return pushInsetTD
    }()
  
  override func perform() {
    if let sourceVC = sourceViewController as? UIViewController,
      destinationVC = destinationViewController as? UIViewController {
        
        destinationVC.transitioningDelegate = transitioningDelegate
        destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        sourceVC.presentViewController(destinationVC, animated: true) {
          println("PushInsetSegue: finished sourceViewController.presentViewController")
        }
    }
  }
  
  deinit {
    println("PushInsetSegue: deinit")
  }
}

class PushInsetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  
  var callingSegue: UIStoryboardSegue?
  
  func animationControllerForPresentedController(
    presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
    println("PushInsetTransitioningDelegate: animationControllerForPresentedController")
    return nil
  }
  
  func animationControllerForDismissedController(
    dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
    println("PushInsetTransitioningDelegate: animationControllerForDismissedController")
    callingSegue = nil
    return nil
  }
  
  func interactionControllerForPresentation(
    animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
    println("PushInsetTransitioningDelegate: interactionControllerForPresentation")
    return nil
  }
  
  func interactionControllerForDismissal(
    animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
    println("PushInsetTransitioningDelegate: interactionControllerForDismissal")
    return nil
  }
  
  func presentationControllerForPresentedViewController(
    presented: UIViewController,
    presentingViewController presenting: UIViewController!,
    sourceViewController source: UIViewController)
    -> UIPresentationController? {
    println("PushInsetTransitioningDelegate: presentationControllerForPresentedViewController")
    return InsetPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
}

class InsetPresentationController: UIPresentationController {
  
  lazy var dimmingView: UIView = {
    let dimmingV = UIView(frame: CGRectZero)
    dimmingV.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
    dimmingV.alpha = 0.0
    return dimmingV
    }()

  override func presentationTransitionWillBegin() {
    println("InsetPresentationController: presentationTransitionWillBegin")
    containerView.addSubview(dimmingView)
    
    let transitionCoordinator = presentedViewController.transitionCoordinator()
    transitionCoordinator?.animateAlongsideTransition(
      { _ in self.dimmingView.alpha = 1.0 }, completion: nil)
  }

  override func presentationTransitionDidEnd(completed: Bool) {
    println("InsetPresentationController: presentationTransitionDidEnd")
    if (!completed) {
      dimmingView.removeFromSuperview()
    }
  }
  
  override func dismissalTransitionWillBegin() {
    println("InsetPresentationController: dismissalTransitionWillBegin")

    let transitionCoordinator = presentedViewController.transitionCoordinator()
    transitionCoordinator?.animateAlongsideTransition(
      { _ in self.dimmingView.alpha = 0.0 }, completion: nil)
}

  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    presentedView().frame = insetFrame
    dimmingView.frame = containerView.bounds
  }

  override func frameOfPresentedViewInContainerView() -> CGRect {
    
    return insetFrame
  }

  var insetFrame: CGRect {
    
    let insetPctWidth:  CGFloat = PushInsetSegue.Const.InsetWidthPct
    let insetPctHeight: CGFloat = PushInsetSegue.Const.InsetHeightPct
    
    let containerBounds = containerView.bounds
    
    let insetX = containerBounds.size.width  * (100.0 - insetPctWidth)  / 100.0 / 2.0
    let insetY = containerBounds.size.height * (100.0 - insetPctHeight) / 100.0 / 2.0
    
    let insetRect = CGRectInset(containerBounds, insetX, insetY)
    
    return insetRect
  }
}