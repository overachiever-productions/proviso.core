﻿namespace Proviso.Core.Interfaces
{
    public interface IDefinable
    {
       string Name { get; }
       string ModelPath { get; }
       string TargetPath { get; }
       bool Skip { get; }
       string SkipReason { get; }
       Impact Impact { get; set; }

       void SetExpectFromParameter(object expect);
       void SetExtractFromParameter(object expect);
       void SetThrowOnConfig(string message);
    }
}